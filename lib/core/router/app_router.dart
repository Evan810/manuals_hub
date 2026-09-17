import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/app/pages/application.dart';
import '../../features/manuals/pages/manuals_chapter_page.dart';
import '../../features/manuals/pages/manuals_list_page.dart';
import 'app_routes.dart';

// 这一行必须写，build_runner 会根据它生成 app_router.g.dart。
part 'app_router.g.dart';

/// 应用级路由 Provider。
///
/// keepAlive 表示这个路由对象在应用运行期间保持稳定。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    // 应用启动后默认进入首页。
    initialLocation: AppRoutes.home,
    routes: [
      // / -> 应用首页
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomePage(),
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
    ],
  );
}
