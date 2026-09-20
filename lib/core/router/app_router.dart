import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '/features/app_route.dart';

import '../../features/zkcd/views/zkcd_menu_page.dart';

// 这一行必须写，build_runner 会根据它生成 app_router.g.dart。
part 'app_router.g.dart';

/// 应用级路由 Provider。
///
/// keepAlive 表示这个路由对象在应用运行期间保持稳定。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    // 应用启动后默认进入应用首页。
    initialLocation: AppRoutes.home,
    routes: [
      // /home -> 应用首页
      GoRoute(path: AppRoutes.home, builder: (_, _) => const Application()),

      // / -> ZKCD 功能菜单（复刻截图 UI）
      GoRoute(
        path: AppRoutes.zkcdMenu,
        builder: (_, _) => const ZkcdMenuPage(),
      ),

      // /categoryList -> 分类下的手册列表页
      GoRoute(
        path: AppRoutes.categoryList,
        builder: (_, state) {
          final extra = state.extra;
          return CategoryListPage(
            categoryId: extra is CategoryListArgs ? extra.categoryId : null,
            title: extra is CategoryListArgs ? extra.title : null,
          );
        },
      ),

      //GoRoute 传递两个参数，使用 `extra` 传对象是处理 ID 和中文 title
      GoRoute(
        path: AppRoutes.chaptersList,
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final title = extra is ChapterArgs ? extra.title : '手册章节目录';

          return ChapterPage(
            args: ChapterArgs(id: id, title: title),
          );
        },
      ),

      // 章节内容页（章节图片，API 3）
      GoRoute(
        path: AppRoutes.chapterDetail,
        builder: (_, state) {
          final args = state.extra! as ChapterDetailArgs;
          return ManualsDetailPage(args: args);
        },
      ),

      GoRoute(
        path: AppRoutes.accountPage,
        builder: (_, _) => const AccountPage(),
      ),

      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (_, _) => const AccountSettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.disclaimer,
        builder: (_, _) => const AccountInfoPage(
          title: '免责声明',
          body: '本应用提供的内容仅用于学习和信息参考。实际操作前请遵守设备制造商的技术规范、安全规程和现场管理要求。因使用本应用内容产生的任何后果，请以经过确认的专业资料和现场判断为准。',
        ),
      ),

      GoRoute(
        path: AppRoutes.about,
        builder: (_, _) => const AccountInfoPage(
          title: '关于应用',
          body: 'Manuals Hub 是一个用于整理和查阅设备手册的工具，帮助你更快找到章节、关键词和常用操作。当前版本 0.1.0。',
        ),
      ),
    ],
  );
}
