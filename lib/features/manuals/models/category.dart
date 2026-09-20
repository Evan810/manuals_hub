/// 品牌分类。
///
/// 对应接口：`GET /api/categories`
/// - [categoryId]：品牌族编号（0~4），用于查询该族下的手册；
/// - [category]：分类名称，用于界面展示。
class Category {
  const Category({required this.categoryId, required this.category});

  final int categoryId;
  final String category;

  factory Category.fromJson(Map<String, Object?> json) {
    return Category(
      categoryId: json['category_id'] as int,
      category: json['category'] as String,
    );
  }
}
