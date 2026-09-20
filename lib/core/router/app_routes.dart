// 集中管理路由路径，避免页面里到处手写字符串。

class AppRoutes {
  const AppRoutes._();

  // ZKCD 功能菜单（当前首页）
  static const zkcdMenu = "/";

  // 应用首页路径。
  static const home = "/home";

  // 手册列表页真实路径。
  static const categoryList = "/CategoryList";

  // 手册详情页路由模板，`:id` 是路径参数占位符。
  static const chaptersList = "/CategoryList/:id";

  // 章节内容页（章节图片）。
  static const chapterDetail = "/chapter-detail";

  // 我的页面子页面。
  static const accountPage = "/account/accountpage";
  static const accountSettings = "/account/settings";
  static const disclaimer = "/account/disclaimer";
  static const about = "/account/about";

  //  根据手册 id 生成真正用于跳转的路径。
  static String chaptersPath(String id) => '/CategoryList/$id';
}

/// 章节页路由参数：id 进入 URL，title 通过 GoRouter.extra 传递。
class ChapterArgs {
  const ChapterArgs({required this.id, required this.title});

  final String id;
  final String title;
}

/// 章节内容页参数：通过 GoRouter.extra 传递（manual_id + chapter_id）。
class ChapterDetailArgs {
  const ChapterDetailArgs({
    required this.manualId,
    required this.chapterId,
    required this.title,
  });

  final int manualId;
  final int chapterId;
  final String title;
}

/// 分类手册列表页参数：通过 GoRouter.extra 传递。
class CategoryListArgs {
  const CategoryListArgs({required this.categoryId, this.title});

  final int categoryId;
  final String? title;
}
