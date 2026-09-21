/// 资源包下载管理器：清单同步、下载、sha256 校验、流式解压、
/// 原子落盘（.tmp 暂存 → 重命名）、失败保留旧版本、删除清理。
///
/// 存储布局：
///   `<ApplicationSupport>/manual_packs/<categoryId>/<manualRoot>/...`（zip 根即手册内容）
///   `<ApplicationSupport>/manual_packs/.download/<manualId>.zip`（下载临时文件）
/// 安装索引保存在 SharedPreferences 键 [_indexKey]，记录每包的 sha256，
/// 用于版本匹配与升级判断。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pack_models.dart';

class InstalledPackSummary {
  const InstalledPackSummary({
    required this.manualId,
    required this.title,
    required this.categoryId,
    required this.path,
    required this.sizeBytes,
    required this.sha256,
  });

  final int manualId;
  final String title;
  final int categoryId;
  final String path;
  final int sizeBytes;
  final String sha256;
}

class PackManager extends ChangeNotifier {
  PackManager({required Dio dio, required SharedPreferences prefs}) {
    _dio = dio;
    _prefs = prefs;
  }

  static const String _indexKey = 'manual_packs_v1';

  late final Dio _dio;
  late final SharedPreferences _prefs;

  Directory? _root;
  PackManifest? _manifest;

  /// manualId -> 安装记录（来自持久化索引）。
  final Map<int, Map<String, dynamic>> _index = {};

  /// 运行时状态（下载进度/错误等）。
  final Map<int, PackEntryState> _states = {};

  /// 同一手册的下载串行锁。
  final Map<int, Future<void>> _locks = {};

  bool _initialized = false;

  // ---------------- 查询 ----------------

  PackEntryState stateFor(int manualId) =>
      _states[manualId] ?? const PackEntryState();

  /// 内置手册恒为可用；非内置手册需状态为 ready。
  bool isReady(int manualId, {required bool bundled}) =>
      bundled || _states[manualId]?.status == PackStatus.ready;

  PackManifest? get manifest => _manifest;

  List<InstalledPackSummary> installedPacks() {
    final result = <InstalledPackSummary>[];
    for (final entry in _index.entries) {
      final v = entry.value;
      result.add(
        InstalledPackSummary(
          manualId: entry.key,
          title: v['title'] as String? ?? '',
          categoryId: v['category_id'] as int? ?? 0,
          path: v['path'] as String? ?? '',
          sizeBytes: v['size'] as int? ?? 0,
          sha256: v['sha256'] as String? ?? '',
        ),
      );
    }
    return result..sort((a, b) => a.manualId.compareTo(b.manualId));
  }

  /// 供 LocalAssetServer 调用：定位已下载包内文件。
  File? packFile(int categoryId, String manualRoot, List<String> rest) {
    final root = _root;
    if (root == null) return null;
    final file = File(
      p.joinAll([root.path, '$categoryId', manualRoot, ...rest]),
    );
    return file.isAbsolute && _isWithin(root.path, file.path) ? file : null;
  }

  // ---------------- 初始化 / 清单 ----------------

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final support = await getApplicationSupportDirectory();
    _root = Directory(p.join(support.path, 'manual_packs'));
    await _root!.create(recursive: true);

    final raw = _prefs.getString(_indexKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = _decodeJson(raw);
      if (decoded is Map) {
        decoded.forEach((key, value) {
          final id = int.tryParse('$key');
          if (id != null && value is Map) {
            _index[id] = Map<String, dynamic>.from(value);
          }
        });
      }
    }

    // 清单尚未拉取时，先依据本地索引标记 ready（文件存在才认）。
    for (final entry in _index.entries) {
      final cat = entry.value['category_id'];
      final rootPath = entry.value['path'];
      if (cat is int && rootPath is String) {
        final dir = Directory(p.join(_root!.path, '$cat', rootPath));
        if (dir.existsSync()) {
          _states[entry.key] = const PackEntryState(status: PackStatus.ready);
        }
      }
    }
    notifyListeners();
  }

  /// 拉取服务端资源包清单并与本地安装记录对账（升级/回滚依据 sha256）。
  Future<PackManifest> loadManifest({bool force = false}) async {
    final cached = _manifest;
    if (cached != null && !force) return cached;

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/packs',
      options: Options(responseType: ResponseType.json),
    );
    final manifest = PackManifest.fromJson(response.data ?? {});
    _manifest = manifest;
    _reconcile();
    return manifest;
  }

  void _reconcile() {
    final manifest = _manifest;
    if (manifest == null || _root == null) return;

    for (final info in manifest.packs) {
      final installed = _index[info.manualId];
      final dir = Directory(
        p.join(_root!.path, '${info.categoryId}', info.path),
      );
      if (dir.existsSync()) {
        // 旧版本目录仍在 → 保持可用；仅当 sha256 落后时标记可更新。
        final sameVersion =
            installed != null && installed['sha256'] == info.sha256;
        _states[info.manualId] = PackEntryState(
          status: PackStatus.ready,
          info: info,
          hasUpdate: !sameVersion,
        );
      } else {
        // 未安装或文件缺失 → 下载。
        _states[info.manualId] = PackEntryState(
          status: PackStatus.absent,
          info: info,
        );
      }
    }
    notifyListeners();
  }

  // ---------------- 下载 / 解压 ----------------

  /// 确保某非内置手册的资源包已安装；内置手册不应调用本方法。
  Future<void> ensureInstalled(int manualId) {
    final existing = _locks[manualId];
    if (existing != null) return existing;
    final task = _runInstall(manualId).whenComplete(() {
      _locks.remove(manualId);
    });
    _locks[manualId] = task;
    return task;
  }

  Future<void> _runInstall(int manualId) async {
    await initialize();
    final manifest = _manifest ?? await loadManifest();
    final info = manifest.forManual(manualId);
    if (info == null) {
      _emitError(manualId, '该手册暂不支持下载');
      return;
    }
    final current = _states[manualId];
    if (current != null &&
        current.status == PackStatus.ready &&
        !current.hasUpdate) {
      return;
    }

    _setState(
      manualId,
      PackEntryState(status: PackStatus.downloading, progress: 0, info: info),
    );

    final tmpDir = Directory(p.join(_root!.path, '.download'));
    await tmpDir.create(recursive: true);
    final zipPath = p.join(tmpDir.path, '$manualId.zip');
    final zipFile = File(zipPath);
    if (zipFile.existsSync()) zipFile.deleteSync();

    try {
      await _downloadWithHash(info, zipFile, manualId);
      await _extractAtomically(info, zipPath);
      await _persistIndex(info);

      _setState(
        manualId,
        PackEntryState(status: PackStatus.ready, progress: 1, info: info),
      );
    } catch (e) {
      // 解压/校验失败时保留旧版本目录，旧索引不被覆盖，可继续使用并可重试。
      final installed = _index[manualId];
      final dir = Directory(
        p.join(_root!.path, '${info.categoryId}', info.path),
      );
      if (installed != null && dir.existsSync()) {
        _setState(
          manualId,
          PackEntryState(
            status: PackStatus.ready,
            progress: 1,
            info: info,
            hasUpdate: installed['sha256'] != info.sha256,
          ),
        );
      } else {
        _emitError(manualId, _humanizeError(e));
      }
    } finally {
      final tmp = File(zipPath);
      if (tmp.existsSync()) {
        try {
          tmp.deleteSync();
        } catch (_) {
          /* 忽略临时文件清理失败 */
        }
      }
    }
  }

  Future<void> _downloadWithHash(
    PackInfo info,
    File target,
    int manualId,
  ) async {
    final response = await _dio.get<ResponseBody>(
      info.url,
      options: Options(responseType: ResponseType.stream),
    );
    final body = response.data;
    if (body == null) throw const PackException('下载内容为空');

    final sink = target.openWrite();
    // 边落盘边计算 sha256（大文件不可一次性读入内存）。
    final hashAccumulator = AccumulatorSink<Digest>();
    final hashSink = sha256.startChunkedConversion(hashAccumulator);
    var received = 0;
    var lastNotify = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      await for (final chunk in body.stream) {
        hashSink.add(chunk);
        sink.add(chunk);
        received += chunk.length;
        final now = DateTime.now();
        if (info.packedSize > 0 &&
            now.difference(lastNotify).inMilliseconds >= 200) {
          lastNotify = now;
          _setState(
            manualId,
            PackEntryState(
              status: PackStatus.downloading,
              progress: (received / info.packedSize).clamp(0, 1),
              info: info,
            ),
          );
        }
      }
      await sink.flush();
    } finally {
      await sink.close();
      hashSink.close();
    }

    final actual = hashAccumulator.events.single.toString();
    if (actual != info.sha256) {
      throw PackException('校验失败：文件哈希不匹配（可能下载不完整）');
    }
  }

  Future<void> _extractAtomically(PackInfo info, String zipPath) async {
    final catDir = Directory(p.join(_root!.path, '${info.categoryId}'));
    final finalDir = Directory(p.join(catDir.path, info.path));
    final staging = Directory(
      p.join(
        catDir.path,
        '.${info.path}.tmp-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    if (staging.existsSync()) {
      staging.deleteSync(recursive: true);
    }
    await staging.create(recursive: true);

    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeBuffer(input);
      for (final entry in archive) {
        final name = entry.name;
        if (_isUnsafeEntry(name)) {
          throw PackException('资源包包含非法路径: $name');
        }
        final outPath = p.join(staging.path, name);
        if (entry.isFile) {
          Directory(p.dirname(outPath)).createSync(recursive: true);
          final output = OutputFileStream(outPath);
          try {
            entry.writeContent(output, freeMemory: true);
          } finally {
            output.close();
          }
        } else {
          Directory(outPath).createSync(recursive: true);
        }
      }
    } finally {
      input.close();
    }

    final entryFile = File(p.join(staging.path, info.entry));
    if (!entryFile.existsSync()) {
      staging.deleteSync(recursive: true);
      throw PackException('资源包缺少入口文件: ${info.entry}');
    }

    // 原子切换：旧版本先改名保留，新版本就位后再删除。
    Directory? backup;
    if (finalDir.existsSync()) {
      backup = Directory(
        '${finalDir.path}.old-${DateTime.now().millisecondsSinceEpoch}',
      );
      finalDir.renameSync(backup.path);
    }
    try {
      staging.renameSync(finalDir.path);
    } catch (_) {
      if (backup != null) backup.renameSync(finalDir.path);
      rethrow;
    }
    if (backup != null && backup.existsSync()) {
      try {
        backup.deleteSync(recursive: true);
      } catch (_) {
        /* 删除旧版本失败不影响新包可用 */
      }
    }
  }

  Future<void> _persistIndex(PackInfo info) async {
    _index[info.manualId] = {
      'category_id': info.categoryId,
      'path': info.path,
      'sha256': info.sha256,
      'size': info.sizeBytes,
      'title': info.title,
      'installed_at': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_indexKey, _encodeJson(_index));
  }

  /// 删除已下载的资源包（释放空间）。
  Future<void> deletePack(int manualId) async {
    final record = _index.remove(manualId);
    if (record != null) {
      final cat = record['category_id'];
      final rootPath = record['path'];
      if (cat is int && rootPath is String) {
        final dir = Directory(p.join(_root!.path, '$cat', rootPath));
        if (dir.existsSync()) dir.deleteSync(recursive: true);
      }
      await _prefs.setString(_indexKey, _encodeJson(_index));
    }
    final info = _states[manualId]?.info;
    _setState(manualId, PackEntryState(status: PackStatus.absent, info: info));
  }

  // ---------------- 内部工具 ----------------

  void _setState(int manualId, PackEntryState state) {
    _states[manualId] = state;
    notifyListeners();
  }

  void _emitError(int manualId, String message) {
    final info = _states[manualId]?.info ?? _manifest?.forManual(manualId);
    _setState(
      manualId,
      PackEntryState(status: PackStatus.error, info: info, error: message),
    );
  }

  String _humanizeError(Object error) {
    if (error is PackException) return error.message;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '连接超时，请检查网络后重试';
        case DioExceptionType.connectionError:
          return '无法连接服务器，请检查网络';
        default:
          return '下载失败（${error.response?.statusCode ?? '网络错误'}）';
      }
    }
    return '下载失败：$error';
  }

  bool _isUnsafeEntry(String name) {
    if (p.isAbsolute(name)) return true;
    // zip 内条目必须是相对路径，任何层级出现 ".." 都视为 zip-slip 攻击/坏包。
    return p.split(name).contains('..');
  }

  bool _isWithin(String root, String candidate) {
    final normalizedRoot = p.normalize(root);
    final normalizedCandidate = p.normalize(candidate);
    return normalizedCandidate == normalizedRoot ||
        p.isWithin(normalizedRoot, normalizedCandidate);
  }

  Object? _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  String _encodeJson(Object value) => jsonEncode(value);
}

class PackException implements Exception {
  const PackException(this.message);
  final String message;

  @override
  String toString() => message;
}
