// 集中管理路由路径，避免页面里到处手写字符串。
//
// 深链安全约定：必要标识（分类 id / 手册 id / 章节 id）一律进入 URL
// （path 或 query），不依赖 GoRouter.extra；extra 仅用于可选的中文标题等
// 展示信息，缺失时页面必须能自行兜底，禁止 `state.extra! as XxxArgs` 强转。

class AppRoutes {
  const AppRoutes._();

  // 应用首页路径。
  static const home = "/";

  // ZKCD 功能菜单
  static const zkcdMenu = "/zkcd";

  // 分类下的手册列表页：?id=分类id&title=分类名
  static const categoryList = "/CategoryList";

  // 某手册的章节目录：:id 为 manual_id，?title=手册名
  static const chaptersList = "/CategoryList/:id";

  // 章节图片页（死路由，仅保留深链可达）：:manualId/:chapterId
  static const chapterDetail = "/chapter-detail/:manualId/:chapterId";

  // 本地 HTML 手册阅读页：:id 为 manual_id
  // query: entry=手册内相对路径(默认取库中 entry) / anchor=锚点 / title=标题
  static const localManual = "/manual/:id";

  // 我的页面子页面。
  static const accountPage = "/account/accountpage";
  static const accountSettings = "/account/settings";
  static const packStorage = "/account/packs";
  static const disclaimer = "/account/disclaimer";
  static const about = "/account/about";

  /// 某手册章节目录路径。
  static String chaptersPath(String id, {String? title}) {
    return Uri(
      path: '/CategoryList/$id',
      queryParameters: title == null ? null : {'title': title},
    ).toString();
  }

  /// 分类手册列表路径。
  static String categoryListPath(int categoryId, {String? title}) {
    return Uri(
      path: '/CategoryList',
      queryParameters: {'id': '$categoryId', 'title': ?title},
    ).toString();
  }

  /// 本地手册阅读页路径。
  /// [entryRelative] 为手册根目录内的相对文件；null 时取手册默认入口。
  static String localManualPath(
    int manualId, {
    String? entryRelative,
    String? title,
    String? anchor,
  }) {
    return Uri(
      path: '/manual/$manualId',
      queryParameters: {
        'entry': ?entryRelative,
        'anchor': ?anchor,
        'title': ?title,
      },
    ).toString();
  }
}

/// 章节页参数：id 已在 URL 中，title 为可选展示信息。
class ChapterArgs {
  const ChapterArgs({required this.id, required this.title});

  final String id;
  final String title;
}

/// 章节内容页参数（可由 URL 安全构造）。
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

/// 本地 HTML 手册阅读参数。manualId 是唯一必需标识；
/// [entryRelative] 缺省时由页面按数据库中的手册入口兜底。
class LocalManualArgs {
  const LocalManualArgs({
    required this.manualId,
    required this.title,
    this.entryRelative,
    this.anchor,
  });

  final int manualId;
  final String title;
  final String? entryRelative;
  final String? anchor;
}

/// 分类手册列表页参数（id 已可由 URL 携带，extra 仅兜底）。
class CategoryListArgs {
  const CategoryListArgs({required this.categoryId, this.title});

  final int categoryId;
  final String? title;
}
