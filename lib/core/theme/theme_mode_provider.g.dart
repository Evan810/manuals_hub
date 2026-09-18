// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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
/// final mode = ref.watch(themeModeNotifierProvider);
///
/// // 切换模式
/// ref.read(themeModeNotifierProvider.notifier).setDark();
/// ref.read(themeModeNotifierProvider.notifier).cycle();
/// ```
///
/// 注意：[SharedPreferences] 必须在 `main()` 中预先加载，
/// 并通过 `ProviderScope(overrides: [...])` 注入，避免首次启动时的异步闪烁。

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

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
/// final mode = ref.watch(themeModeNotifierProvider);
///
/// // 切换模式
/// ref.read(themeModeNotifierProvider.notifier).setDark();
/// ref.read(themeModeNotifierProvider.notifier).cycle();
/// ```
///
/// 注意：[SharedPreferences] 必须在 `main()` 中预先加载，
/// 并通过 `ProviderScope(overrides: [...])` 注入，避免首次启动时的异步闪烁。
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
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
  /// final mode = ref.watch(themeModeNotifierProvider);
  ///
  /// // 切换模式
  /// ref.read(themeModeNotifierProvider.notifier).setDark();
  /// ref.read(themeModeNotifierProvider.notifier).cycle();
  /// ```
  ///
  /// 注意：[SharedPreferences] 必须在 `main()` 中预先加载，
  /// 并通过 `ProviderScope(overrides: [...])` 注入，避免首次启动时的异步闪烁。
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'90029b93f2a03fdfaee97cfd8024e0ecfaa66ecf';

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
/// final mode = ref.watch(themeModeNotifierProvider);
///
/// // 切换模式
/// ref.read(themeModeNotifierProvider.notifier).setDark();
/// ref.read(themeModeNotifierProvider.notifier).cycle();
/// ```
///
/// 注意：[SharedPreferences] 必须在 `main()` 中预先加载，
/// 并通过 `ProviderScope(overrides: [...])` 注入，避免首次启动时的异步闪烁。

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 预先加载的 [SharedPreferences] 实例。
///
/// `main()` 中通过 ProviderScope 的 `overrides` 注入真实实例，
/// 否则第一次调用 [SharedPreferences.getInstance] 可能阻塞 UI。

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// 预先加载的 [SharedPreferences] 实例。
///
/// `main()` 中通过 ProviderScope 的 `overrides` 注入真实实例，
/// 否则第一次调用 [SharedPreferences.getInstance] 可能阻塞 UI。

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// 预先加载的 [SharedPreferences] 实例。
  ///
  /// `main()` 中通过 ProviderScope 的 `overrides` 注入真实实例，
  /// 否则第一次调用 [SharedPreferences.getInstance] 可能阻塞 UI。
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'61e2170a2f1a0aefbc038d3ca3f1023d7dd200f2';
