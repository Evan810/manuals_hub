import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_mode_provider.g.dart';

/// 主题模式持久化 Provider。
///
/// 支持三种模式：
///   - [ThemeMode.system]  跟随系统（默认）
///   - [ThemeMode.light]   强制浅色
///   - [ThemeMode.dark]    强制深色
///
/// 用法：
/// ```dart
/// // 读取当前模式
/// final mode = ref.watch(themeModeProvider);
///
/// // 切换模式
/// ref.read(themeModeProvider.notifier).setDark();
/// ref.read(themeModeProvider.notifier).cycle();
/// ```
///
/// 注意：[SharedPreferences] 必须在 `main()` 中预先加载，
/// 并通过 `ProviderScope(overrides: [...])` 注入，避免首次启动时的异步闪烁。
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _prefKey = 'app.theme_mode';

  @override
  ThemeMode build() {
    // 从已预加载的 SharedPreferences 读取；
    // 若 ProviderScope 未注入，则降级为 system。
    final prefs = ref.watch(sharedPreferencesProvider);
    final index = prefs.getInt(_prefKey);
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      return ThemeMode.values[index];
    }
    return ThemeMode.system;
  }

  /// 显式设置主题模式并持久化
  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_prefKey, mode.index);
  }

  /// 强制浅色
  Future<void> setLight() => setMode(ThemeMode.light);

  /// 强制深色
  Future<void> setDark() => setMode(ThemeMode.dark);

  /// 跟随系统
  Future<void> setSystem() => setMode(ThemeMode.system);

  /// 在 system → light → dark → system 之间循环切换
  Future<void> cycle() async {
    const order = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final next = order[(order.indexOf(state) + 1) % order.length];
    await setMode(next);
  }
}

/// 预先加载的 [SharedPreferences] 实例。
///
/// `main()` 中通过 ProviderScope 的 `overrides` 注入真实实例，
/// 否则第一次调用 [SharedPreferences.getInstance] 可能阻塞 UI。
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  // 默认返回一个空的实现（仅作编译占位），
  // 运行时必须由 main() 注入真实实例。
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.overrides',
  );
}
