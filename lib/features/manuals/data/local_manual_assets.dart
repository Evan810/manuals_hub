import '../models/manual.dart';

/// 将目录中的手册定位到 Flutter 打包资源，并拒绝越界路径。
class LocalManualAssetResolver {
  const LocalManualAssetResolver._();

  static String entryAsset(Manual manual) {
    return _assetPath(manual.categoryId, manual.path, manual.entry);
  }

  static String chapterAsset({
    required Manual manual,
    required String? htmlPath,
  }) {
    return _assetPath(manual.categoryId, manual.path, htmlPath ?? manual.entry);
  }

  static String _assetPath(int categoryId, String manualPath, String entry) {
    if (categoryId < 0 || categoryId > 4) {
      throw ArgumentError('非法品牌族编号：$categoryId');
    }
    _validateSegment(manualPath, '手册目录');
    final normalizedEntry = entry.replaceAll('\\', '/');
    if (normalizedEntry.isEmpty ||
        normalizedEntry.startsWith('/') ||
        normalizedEntry.split('/').contains('..')) {
      throw ArgumentError('非法手册入口：$entry');
    }
    return 'assets/$categoryId/$manualPath/$normalizedEntry';
  }

  static void _validateSegment(String value, String name) {
    if (value.isEmpty ||
        value == '.' ||
        value == '..' ||
        value.contains('/') ||
        value.contains('\\')) {
      throw ArgumentError('非法$name：$value');
    }
  }
}
