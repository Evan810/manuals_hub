import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '/features/app_route.dart';

import '../../features/zkcd/views/zkcd_menu_page.dart';
import '../../features/app/views/account/account_info_page.dart';
import '../../features/app/views/account/account_settings_page.dart';

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
      // /manuals -> 新闻列表页
      GoRoute(
        path: AppRoutes.manuals,
        builder: (_, _) => const ManualsListPage(),
      ),
      // /manuals/:id -> 新闻详情页
      GoRoute(
        path: AppRoutes.chaptersList,
        builder: (_, state) {
          // 从路径参数中读取 id，例如 /manuals/article_001 中的 article_001。
          final id = state.pathParameters['id']!;
          return ManualsChapterPage(manualsId: id);
        },
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
