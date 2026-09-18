import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 预先加载 SharedPreferences，避免 Provider 内部异步读取时的启动闪烁。
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ManualsApp(),
    ),
  );
}

/// 应用根组件，负责挂载主题和路由。
class ManualsApp extends ConsumerWidget {
  const ManualsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 从 Riverpod 读取路由。
    final router = ref.watch(appRouterProvider);
    // 从 Riverpod 读取当前主题模式（支持运行时切换 + 持久化）。
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Manuals Course',
      debugShowCheckedModeBanner: false,
      // 浅色 / 深色主题（来自 AppTheme 工厂）
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // 由 Provider 决定：system / light / dark
      themeMode: themeMode,
      // 把 go_router 交给 MaterialApp.router 管理导航。
      routerConfig: router,
    );
  }
}
