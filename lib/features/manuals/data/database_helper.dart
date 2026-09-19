import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static Database? _database;

  static Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  static Future<Database> _openDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = p.join(documentsDirectory.path, 'Manuals.db');

    if (!await File(databasePath).exists()) {
      final data = await rootBundle.load('assets/Manuals.db');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(databasePath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(databasePath, readOnly: true);
  }
}
