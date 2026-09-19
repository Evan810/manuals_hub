import 'package:sqflite/sqflite.dart';

import '../models/manual.dart';
import 'database_helper.dart';

class ManualsRepository {
  const ManualsRepository();

  Future<Database> get _database => DatabaseHelper.database;

  Future<Map<String, int>> getCategories() async {
    final rows = await (await _database).rawQuery('''
      SELECT category, COUNT(*) AS manual_count, MIN(family) AS family
      FROM manuals
      GROUP BY category
      ORDER BY family ASC, category ASC
    ''');

    return {
      for (final row in rows)
        row['category'] as String: row['manual_count'] as int,
    };
  }

  Future<List<Manual>> getManualsByCategory(String category) async {
    final rows = await (await _database).rawQuery(
      '''
      SELECT m.*, COUNT(c.id) AS chapter_count
      FROM manuals m
      LEFT JOIN chapters c ON c.manual_id = m.id
      WHERE m.category = ?
      GROUP BY m.id
      ORDER BY m.id
    ''',
      [category],
    );
    return rows.map(Manual.fromMap).toList();
  }
}
