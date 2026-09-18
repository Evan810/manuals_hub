import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// ZKCD 功能菜单页面（复刻截图 UI）
class ZkcdMenuPage extends StatelessWidget {
  const ZkcdMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部蓝色标题栏（品牌色渐变，浅深通用）
          _buildAppBar(),
          // 主体内容区
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // 紫色功能菜单卡片
                _buildFeatureCard(),
                const SizedBox(height: 16),
                // 菜单项列表（随明暗模式自动取色）
                ..._buildMenuItems(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 顶部标题栏 ====================
  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 48, left: 8, right: 8, bottom: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
          const Expanded(
            child: Text(
              'ZKCD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ==================== 紫色功能菜单卡片（品牌渐变，浅深通用） ====================
  Widget _buildFeatureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            AppColors.featureCardPurpleLight,
            AppColors.featureCardPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.featureCardPurple.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZKCD 功能菜单',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '请选择要进入的功能',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==================== 菜单项数据 ====================
  List<_MenuItemData> get _menuItems => [
    _MenuItemData(
      label: '电梯',
      title: '电梯状态',
      subtitle: '电梯楼层与运行状态',
      bgColor: AppColors.iconElevator,
    ),
    _MenuItemData(
      label: '故障',
      title: '故障',
      subtitle: '查看当前/NS 故障信息',
      bgColor: AppColors.iconFault,
    ),
    _MenuItemData(
      label: 'IO',
      title: 'I/O 查看',
      subtitle: '井道/机房/门信号状态查询',
      bgColor: AppColors.iconIO,
    ),
    _MenuItemData(
      label: 'HMI',
      title: 'HMI',
      subtitle: 'HMI 打开/关闭控制',
      bgColor: AppColors.iconHMI,
    ),
    _MenuItemData(
      label: '印板',
      title: '印板验证',
      subtitle: '印板验证功能',
      bgColor: AppColors.iconPCB,
    ),
    _MenuItemData(
      label: '参数',
      title: '参数修改',
      subtitle: 'NV 参数读取与修改',
      bgColor: AppColors.iconParam,
    ),
    _MenuItemData(
      label: '程序',
      title: '程序信息',
      subtitle: '查看各版本程序信息',
      bgColor: AppColors.iconProgram,
    ),
    _MenuItemData(
      label: '时钟',
      title: '系统时钟',
      subtitle: '电梯时钟读取与设置',
      bgColor: AppColors.iconClock,
    ),
  ];

  // ==================== 菜单项列表（动态读取 Theme 颜色） ====================
  List<Widget> _buildMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? Colors.white;
    final borderColor = theme.dividerColor;
    final primaryText =
        theme.textTheme.titleMedium?.color ?? const Color(0xFF1F2937);
    final secondaryText =
        theme.textTheme.bodySmall?.color ?? const Color(0xFF6B7280);

    return _menuItems.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  _buildIconBadge(item.label, item.bgColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: secondaryText, size: 22),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ==================== 彩色圆形图标（品牌色，浅深通用） ====================
  Widget _buildIconBadge(String label, Color bgColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 菜单项数据模型
class _MenuItemData {
  final String label;
  final String title;
  final String subtitle;
  final Color bgColor;

  const _MenuItemData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });
}
