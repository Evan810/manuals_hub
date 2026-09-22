import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/features/app/app.dart';
import 'package:manuals_hub/features/application.dart';
import 'package:manuals_hub/features/manuals/manuals.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 这一行必须写，build_runner 会根据它生成 app_router.g.dart。
part 'app_router.g.dart';

/// 应用级路由 Provider。

/// keepAlive 表示这个路由对象在应用运行期间保持稳定。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    // 应用启动后默认进入应用首页。
    initialLocation: AppRoutes.home,
    routes: [
      // /home -> 应用首页
      GoRoute(path: AppRoutes.home, builder: (_, _) => const Application()),

      // /CategoryList?id=&title= -> 分类下的手册列表页
      GoRoute(
        path: AppRoutes.categoryList,
        builder: (_, state) {
          // 必要 id 优先取 URL query；extra 仅作兼容兜底。
          final extra = state.extra;
          final categoryId =
              int.tryParse(state.uri.queryParameters['id'] ?? '') ??
              (extra is CategoryListArgs ? extra.categoryId : null);
          final title =
              state.uri.queryParameters['title'] ??
              (extra is CategoryListArgs ? extra.title : null);
          return CategoryListPage(categoryId: categoryId, title: title);
        },
      ),

      // /CategoryList/:id?title= -> 某手册的章节目录
      GoRoute(
        path: AppRoutes.chaptersList,
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final title =
              state.uri.queryParameters['title'] ??
              (extra is ChapterArgs ? extra.title : '手册章节目录');
          return ChapterPage(
            args: ChapterArgs(id: id, title: title),
          );
        },
      ),

      // /chapter-detail/:manualId/:chapterId?title=
      // 当前无页面跳转入口，仅保证深链非法参数时不崩溃。
      GoRoute(
        path: AppRoutes.chapterDetail,
        builder: (_, state) {
          final manualId = int.tryParse(state.pathParameters['manualId'] ?? '');
          final chapterId = int.tryParse(
            state.pathParameters['chapterId'] ?? '',
          );
          final title = state.uri.queryParameters['title'] ?? '章节详情';
          if (manualId == null || chapterId == null) {
            return const _RouteErrorPage(message: '章节链接缺少必要参数');
          }
          return ManualsDetailPage(
            args: ChapterDetailArgs(
              manualId: manualId,
              chapterId: chapterId,
              title: title,
            ),
          );
        },
      ),

      // /manual/:id?entry=&anchor=&title= -> 本地 HTML 手册阅读页
      GoRoute(
        path: AppRoutes.localManual,
        builder: (_, state) {
          final manualId = int.tryParse(state.pathParameters['id'] ?? '');
          if (manualId == null) {
            return const _RouteErrorPage(message: '手册链接缺少必要参数');
          }
          final query = state.uri.queryParameters;
          return LocalManualPage(
            manualId: manualId,
            title: query['title'] ?? '手册',
            entryRelative: query['entry'],
            anchor: query['anchor'],
          );
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
        path: AppRoutes.packStorage,
        builder: (_, _) => const PackStoragePage(),
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

      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.loginCode,
        builder: (_, _) => const LoginCodePage(),
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
    ],
  );
}

/// 深链/恢复页面参数非法时的安全兜底页。
class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('无法打开页面')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
