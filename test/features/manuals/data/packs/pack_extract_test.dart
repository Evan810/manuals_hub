import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manuals_hub/features/manuals/data/packs/pack_manager.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pack_extract_test');
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  File writeZip(Archive archive, String name) {
    final zipPath = p.join(tmp.path, name);
    File(zipPath).writeAsBytesSync(ZipEncoder().encode(archive)!);
    return File(zipPath);
  }

  group('extractZipToDirectory', () {
    test('DEFLATE 与 STORE 条目均按原始字节落盘（回归：0 字节文件）', () {
      // 高度重复的字节序列会被 ZipEncoder 压缩为 DEFLATE 条目。
      final deflated = List<int>.generate(20000, (i) => i % 251);
      final stored = utf8.encode('<html>hello pack</html>');

      final archive = Archive()
        ..addFile(ArchiveFile('index.html', stored.length, stored))
        ..addFile(ArchiveFile('html/001/page.bin', deflated.length, deflated))
        ..addFile(
          ArchiveFile.noCompress(
            'raw/logo.bin',
            4,
            Uint8List.fromList([0, 1, 2, 3]),
          ),
        );
      final zipFile = writeZip(archive, 'pack.zip');

      final out = Directory(p.join(tmp.path, 'out'))..createSync();
      extractZipToDirectory(zipFile.path, out);

      expect(File(p.join(out.path, 'index.html')).readAsBytesSync(), stored);
      expect(
        File(p.join(out.path, 'html/001/page.bin')).readAsBytesSync(),
        deflated,
      );
      expect(File(p.join(out.path, 'raw/logo.bin')).readAsBytesSync(), [0, 1, 2, 3]);
    });

    test('空目录条目会被创建', () {
      final archive = Archive()..addFile(ArchiveFile('empty/', 0, ''));
      final zipFile = writeZip(archive, 'dirs.zip');

      final out = Directory(p.join(tmp.path, 'out'))..createSync();
      extractZipToDirectory(zipFile.path, out);

      expect(Directory(p.join(out.path, 'empty')).existsSync(), isTrue);
    });

    test('zip-slip 条目（包含 ..）被拒绝且不落盘', () {
      final archive = Archive()
        ..addFile(ArchiveFile('../evil.txt', 5, utf8.encode('evil!')));
      final zipFile = writeZip(archive, 'evil.zip');

      final out = Directory(p.join(tmp.path, 'out'))..createSync();
      expect(
        () => extractZipToDirectory(zipFile.path, out),
        throwsA(isA<PackException>()),
      );
      expect(File(p.join(tmp.path, 'evil.txt')).existsSync(), isFalse);
    });
  });
}
