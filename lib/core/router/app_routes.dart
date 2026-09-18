// 集中管理路由路径，避免页面里到处手写字符串。
class AppRoutes {
  const AppRoutes._();

  // ZKCD 功能菜单（当前首页）
  static const zkcdMenu = "/";

  // 应用首页路径。
  static const home = "/home";

  // 手册列表页真实路径。
  static const manuals = "/manuals";

  // 手册详情页路由模板，`:id` 是路径参数占位符。
  static const chaptersList = "/manuals/:id";

  // 我的页面子页面。
  static const accountSettings = "/account/settings";
  static const disclaimer = "/account/disclaimer";
  static const about = "/account/about";

  //  根据手册 id 生成真正用于跳转的路径。
  static String chaptersPath(String id) => '/manuals/$id';
}
