import 'package:flutter_test/flutter_test.dart';
import 'package:manuals_hub/features/manuals/data/local_manual_assets.dart';
import 'package:manuals_hub/features/manuals/models/manual.dart';

void main() {
  const manual = Manual(
    id: 1,
    title: 'Test manual',
    categoryId: 2,
    category: 'Test',
    path: 'example',
    entry: 'html/index.html',
  );

  group('LocalManualAssetResolver', () {
    test('builds an asset path for a valid manual entry', () {
      expect(
        LocalManualAssetResolver.entryAsset(manual),
        'assets/2/example/html/index.html',
      );
    });

    test('normalizes Windows separators in a chapter path', () {
      expect(
        LocalManualAssetResolver.chapterAsset(
          manual: manual,
          htmlPath: r'html\chapter-1.html',
        ),
        'assets/2/example/html/chapter-1.html',
      );
    });

    test('rejects path traversal in a chapter path', () {
      expect(
        () => LocalManualAssetResolver.chapterAsset(
          manual: manual,
          htmlPath: '../secrets.html',
        ),
        throwsArgumentError,
      );
    });

    test('rejects an invalid manual directory', () {
      const invalidManual = Manual(
        id: 2,
        title: 'Invalid',
        categoryId: 0,
        category: 'Test',
        path: '../other',
        entry: 'index.html',
      );

      expect(
        () => LocalManualAssetResolver.entryAsset(invalidManual),
        throwsArgumentError,
      );
    });
  });
}
