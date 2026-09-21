import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/chapter.dart';
import '../models/category.dart';
import '../models/manual.dart';

/// 读取随 App 打包的只读手册数据库（本地优先数据源）。
///
/// 数据完整性由构建管线保证（assets/build_manuals_db.py 预校验 +
/// audit_assets.py 审计），运行时不再按 asset 是否存在过滤手册/章节：
/// 非内置手册的资源来自按需下载的资源包，同样由 [LocalAssetServer] 提供。
class LocalManualRepository {
  LocalManualRepository._();

  static final instance = LocalManualRepository._();
  late final Database _database;
  Future<void>? _initialization;

  final Map<int, Future<List<Manual>>> _manualsByCategory = {};
  final Map<int, Future<Manual>> _manualsById = {};
  final Map<int, Future<List<Chapter>>> _chaptersByManual = {};
  Future<List<Category>>? _categories;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    final databasePath = path.join(await getDatabasesPath(), 'Manuals.db');
    final databaseFile = File(databasePath);
    final versionFile = File('$databasePath.asset-version');
    final data = await rootBundle.load('assets/Manuals.db');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final bundledVersion = _contentVersion(bytes);
    final installedVersion = await _readVersion(versionFile);

    if (!await databaseFile.exists() || installedVersion != bundledVersion) {
      await _replaceDatabase(databaseFile, versionFile, bytes, bundledVersion);
    }

    _database = await openDatabase(databasePath, readOnly: true);
  }

  Future<List<Category>> getCategories() => _categories ??= _loadCategories();

  Future<List<Category>> _loadCategories() async {
    final rows = await _database.rawQuery('''
      SELECT category_id, category
      FROM manuals
      GROUP BY category_id, category
      ORDER BY category_id ASC
    ''');
    return rows
        .map((row) => Category.fromJson(row.cast<String, Object?>()))
        .toList(growable: false);
  }

  Future<List<Manual>> getManuals(int categoryId) => _manualsByCategory
      .putIfAbsent(categoryId, () => _loadManuals(categoryId));

  Future<List<Manual>> _loadManuals(int categoryId) async {
    // 一次 JOIN/GROUP BY 取章节数，避免 UI 中逐条 N+1 查询。
    final rows = await _database.query(
      'manuals m LEFT JOIN chapters c ON c.manual_id = m.id',
      columns: [
        'm.id',
        'm.title',
        'm.category_id',
        'm.category',
        'm.path',
        'm.icon',
        'm.entry',
        'm.bundled',
        'COUNT(c.id) AS chapter_count',
      ],
      where: 'm.category_id = ?',
      whereArgs: [categoryId],
      groupBy: 'm.id',
      orderBy: 'm.id ASC',
    );
    return rows
        .map((row) => Manual.fromJson(row.cast<String, Object?>()))
        .toList(growable: false);
  }

  Future<Manual> getManual(int manualId) =>
      _manualsById.putIfAbsent(manualId, () => _loadManual(manualId));

  Future<Manual> _loadManual(int manualId) async {
    final rows = await _database.query(
      'manuals',
      where: 'id = ?',
      whereArgs: [manualId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('手册不存在：$manualId');
    }
    final row = rows.single;
    final chapters = await _database.rawQuery(
      'SELECT COUNT(*) AS count FROM chapters WHERE manual_id = ?',
      [manualId],
    );
    return Manual.fromJson(
      {
        ...row,
        'chapter_count': chapters.first['count'],
      }.cast<String, Object?>(),
    );
  }

  Future<List<Chapter>> getChapters(int manualId) =>
      _chaptersByManual.putIfAbsent(manualId, () => _loadChapters(manualId));

  Future<List<Chapter>> _loadChapters(int manualId) async {
    final rows = await _database.query(
      'chapters',
      where: 'manual_id = ?',
      whereArgs: [manualId],
      orderBy: 'chapter_no ASC',
    );
    return rows
        .map(
          (row) => Chapter.fromJson({
            'chapter_id': row['id'],
            'chapter_no': row['chapter_no'],
            'title': row['title'],
            'html_path': row['html_path'],
            'page_start': row['page_start'],
            'page_end': row['page_end'],
            'is_reader': row['page_start'] != null,
          }),
        )
        .toList(growable: false);
  }

  Future<String?> _readVersion(File versionFile) async {
    if (!await versionFile.exists()) return null;
    return versionFile.readAsString();
  }

  Future<void> _replaceDatabase(
    File databaseFile,
    File versionFile,
    List<int> bytes,
    String version,
  ) async {
    final temporaryFile = File('${databaseFile.path}.tmp');
    final backupFile = File('${databaseFile.path}.previous');
    await temporaryFile.writeAsBytes(bytes, flush: true);

    if (await backupFile.exists()) await backupFile.delete();
    if (await databaseFile.exists()) await databaseFile.rename(backupFile.path);
    await temporaryFile.rename(databaseFile.path);
    await versionFile.writeAsString(version, flush: true);
    if (await backupFile.exists()) await backupFile.delete();
  }

  /// 内置库版本：长度 + FNV-1a 哈希。App 升级内置库后启动即原子替换。
  String _contentVersion(List<int> bytes) {
    var hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash = (hash ^ byte) * 0x01000193 & 0xffffffff;
    }
    return '${bytes.length}-${hash.toRadixString(16)}';
  }
}
