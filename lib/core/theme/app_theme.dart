import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 应用主题入口：提供浅色 / 深色两套完整 ThemeData。
///
/// 约定：
///   - 业务页面**禁止**直接引用 [AppColors] 中会随明暗变化的背景/卡片/文字色，
///     一律通过 `Theme.of(context)` 或 `Theme.of(context).colorScheme` 获取。
///   - [AppColors] 中品牌色、图标色、状态色为浅深通用，可直接引用。
class AppTheme {
  AppTheme._();

  /// 应用主品牌色（浅色 / 深色共用同一 seed）
  static const _seed = AppColors.primaryBlue;

  // ==================== 对外工厂 ====================

  /// 浅色主题
  static ThemeData light() => _build(Brightness.light);

  /// 深色主题
  static ThemeData dark() => _build(Brightness.dark);

  // ==================== 核心构建 ====================

  static ThemeData _build(Brightness brightness) {
    final palette = AppThemePalette.of(brightness);
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    // 深色模式下 AppBar 品牌蓝轻微压暗，避免刺眼
    final appBarBg = brightness == Brightness.dark
        ? Color.lerp(_seed, Colors.black, 0.25)!
        : _seed;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,

      scaffoldBackgroundColor: palette.pageBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      textTheme: _buildTextTheme(palette),

      cardTheme: CardThemeData(
        color: palette.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.cardBorder, width: 0.5),
        ),
      ),

      dividerColor: palette.cardBorder,
      splashColor: _seed.withValues(alpha: 0.12),
      highlightColor: _seed.withValues(alpha: 0.08),
    );
  }

  // ==================== TextTheme ====================

  static TextTheme _buildTextTheme(AppThemePalette palette) {
    return TextTheme(
      displayLarge: TextStyle(color: palette.textPrimary, fontSize: 32, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(color: palette.textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: palette.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: palette.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: palette.textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: palette.textSecondary, fontSize: 12),
      labelLarge: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: palette.textSecondary, fontSize: 12),
    );
  }
}
