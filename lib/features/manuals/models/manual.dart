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
    required this.entry,
    this.icon = '',
    this.chapterCount = 0,
    this.entryUrl,
  });

  /// 手册 id（接口字段 manual_id）。
  final int id;

  final String title;

  /// 品牌族编号，用于归类。
  final int categoryId;

  /// 分类名称。
  final String category;

  /// 手册入口文件名，如 index.html。
  final String entry;

  /// 图标文件名（App 本地 assets/icons/ 下打包）。
  final String icon;

  final int chapterCount;

  /// 手册入口完整地址。
  final String? entryUrl;

  /// 本地打包的图标资源路径（assets/icons/ 下）。
  /// 如果接口返回的 icon 非空，返回 'assets/icons/xxx.png'。
  String? get localIconPath =>
      icon.isEmpty ? null : 'assets/icons/$icon';

  factory Manual.fromJson(Map<String, Object?> json) {
    final entryUrl = json['entry_url'] as String?;
    return Manual(
      id: (json['manual_id'] ?? json['id']) as int,
      title: json['title'] as String,
      categoryId: json['category_id'] as int? ?? 0,
      category: json['category'] as String,
      entry: json['entry'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      chapterCount: json['chapter_count'] as int? ?? 0,
      entryUrl: entryUrl == null ? null : DioClient.resolveUrl(entryUrl),
    );
  }
}
