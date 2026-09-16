import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

void main() {
  // ProviderScope 是 Riverpod 的根容器，所有 Provider 都需要它。
  runApp(const ProviderScope(child: ManualsApp()));
}

/// 应用根组件，负责挂载主题和路由。
class ManualsApp extends ConsumerWidget {
  const ManualsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 从 Riverpod 读取 GoRouter 对象。
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Manuals Course',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        useMaterial3: true,
      ),
      // 把 go_router 交给 MaterialApp.router 管理导航。
      routerConfig: router,
    );
  }
}
