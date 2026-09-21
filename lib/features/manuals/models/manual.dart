import 'package:manuals_hub/core/network/dio_client.dart';

/// 一本手册。
///
/// 对应接口：`GET /api/manuals?category_id={category_id}`
class Manual {
  const Manual({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.category,
    required this.path,
    required this.entry,
    this.icon = '',
    this.chapterCount = 0,
    this.bundled = false,
    this.entryUrl,
  });

  /// 手册 id（接口字段 manual_id）。
  final int id;

  final String title;

  /// 品牌族编号，用于归类。
  final int categoryId;

  /// 分类名称。
  final String category;

  /// 手册在打包资源中的目录名。
  final String path;

  /// 手册入口文件名，如 index.html。
  final String entry;

  /// 图标文件名（App 本地 assets/icons/ 下打包）。
  final String icon;

  final int chapterCount;

  /// true：随安装包内置；false：按需下载资源包。
  final bool bundled;

  /// 手册入口完整地址。
  final String? entryUrl;

  /// 本地打包的图标资源路径（assets/icons/ 下）。
  /// 如果接口返回的 icon 非空，返回 'assets/icons/xxx.png'。
  String? get localIconPath => icon.isEmpty ? null : 'assets/icons/$icon';

  factory Manual.fromJson(Map<String, Object?> json) {
    final entryUrl = json['entry_url'] as String?;
    // SQLite 返回 0/1（int），API 返回 true/false（bool）。
    final rawBundled = json['bundled'];
    final bundled = rawBundled == true || rawBundled == 1;
    return Manual(
      id: (json['manual_id'] ?? json['id']) as int,
      title: json['title'] as String,
      categoryId: json['category_id'] as int? ?? 0,
      category: json['category'] as String,
      path: json['path'] as String? ?? '',
      entry: json['entry'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      chapterCount: json['chapter_count'] as int? ?? 0,
      bundled: bundled,
      entryUrl: entryUrl == null ? null : DioClient.resolveUrl(entryUrl),
    );
  }
}
