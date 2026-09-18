import 'package:flutter/material.dart';

/// 应用主题颜色常量（基于截图 ZKCD 功能菜单分析）
///
/// 使用说明：
///   - 品牌 / 功能图标色（static const）浅深模式通用，可直接引用。
///   - 页面背景、卡片背景、文字色等会随明暗模式变化，
///     应通过 `Theme.of(context)` 从 ThemeData / ColorScheme 中读取，
///     不要直接引用本文件中的颜色值。
class AppColors {
  AppColors._();

  // ==================== 主品牌色（浅深通用） ====================

  /// 主品牌蓝 - 顶部状态栏、标题栏
  static const Color primaryBlue = Color(0xFF3B82F6);

  /// 主品牌蓝 深色（用于渐变终点）
  static const Color primaryBlueDark = Color(0xFF2563EB);

  // ==================== 功能卡片色（浅深通用） ====================

  /// 功能菜单主卡片（紫靛色）背景
  static const Color featureCardPurple = Color(0xFF5B21B6);

  /// 功能菜单主卡片 渐变起始（更亮的紫色）
  static const Color featureCardPurpleLight = Color(0xFF7C3AED);

  // ==================== 菜单项图标色（每项独立，浅深通用） ====================

  /// 电梯状态 - 琥珀橙
  static const Color iconElevator = Color(0xFFF59E0B);

  /// 故障 - 红色
  static const Color iconFault = Color(0xFFEF4444);

  /// I/O 查看 - 红色
  static const Color iconIO = Color(0xFFEF4444);

  /// HMI - 蓝色
  static const Color iconHMI = Color(0xFF3B82F6);

  /// 印板验证 - 紫色
  static const Color iconPCB = Color(0xFF8B5CF6);

  /// 参数修改 - 青色
  static const Color iconParam = Color(0xFF06B6D4);

  /// 程序信息 - 绿色
  static const Color iconProgram = Color(0xFF10B981);

  /// 系统时钟 - 靛蓝色
  static const Color iconClock = Color(0xFF6366F1);

  // ==================== 状态通用色 ====================

  /// 紫色卡片上的文字（白色）
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// 成功/确认绿色
  static const Color success = Color(0xFF10B981);

  /// 警告黄色
  static const Color warning = Color(0xFFF59E0B);

  /// 错误/危险红色
  static const Color error = Color(0xFFEF4444);
}

// ==================== 明暗模式动态色 ====================
// 仅由 AppTheme 内部使用，业务页面禁止直接引用。

class _LightPalette {
  _LightPalette._();
  static const pageBackground = Color(0xFFF3F4F6);
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
}

class _DarkPalette {
  _DarkPalette._();
  static const pageBackground = Color(0xFF121212);
  static const cardBackground = Color(0xFF1E1E1E);
  static const cardBorder = Color(0xFF333333);
  static const textPrimary = Color(0xFFE5E7EB);
  static const textSecondary = Color(0xFF9CA3AF);
}

/// 一整套主题配色（对应某一种 Brightness），
/// 供 AppTheme 内部构建 ThemeData 使用。
class AppThemePalette {
  final Color pageBackground;
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;

  const AppThemePalette._({
    required this.pageBackground,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
  });

  /// 根据 Brightness 获取对应的一整套 Palette
  static AppThemePalette of(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppThemePalette._(
      pageBackground: isDark ? _DarkPalette.pageBackground : _LightPalette.pageBackground,
      cardBackground: isDark ? _DarkPalette.cardBackground : _LightPalette.cardBackground,
      cardBorder: isDark ? _DarkPalette.cardBorder : _LightPalette.cardBorder,
      textPrimary: isDark ? _DarkPalette.textPrimary : _LightPalette.textPrimary,
      textSecondary: isDark ? _DarkPalette.textSecondary : _LightPalette.textSecondary,
    );
  }
}
