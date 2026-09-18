import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

class HmWidget extends StatelessWidget {
  const HmWidget({super.key});

  List<_MenuItemData> get _menuItems => const [
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = theme.dividerColor;
    final primaryText =
        theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final secondaryText =
        theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push(AppRoutes.categoryList),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
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
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                              ),
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
        },
      ),
    );
  }

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
