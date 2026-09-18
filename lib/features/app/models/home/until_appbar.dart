import 'package:flutter/material.dart';

import 'package:manuals_hub/core/theme/app_colors.dart';

class HmAppbar extends SliverPersistentHeaderDelegate {
  HmAppbar({
    required this.topPadding,
    required this.title,
    required this.onAccount,
    this.onSearch,
  });

  final double topPadding;
  final String title;
  final VoidCallback onAccount;
  final VoidCallback? onSearch;

  static const double _toolbarHeight = 64;

  @override
  double get minExtent => topPadding + _toolbarHeight;

  @override
  double get maxExtent => topPadding + _toolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 深色模式下品牌蓝压暗 25%，避免刺眼
    final startColor = isDark
        ? Color.lerp(AppColors.primaryBlue, Colors.black, 0.25)!
        : AppColors.primaryBlue;
    final endColor = isDark
        ? Color.lerp(AppColors.primaryBlueDark, Colors.black, 0.25)!
        : AppColors.primaryBlueDark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(top: topPadding, left: 8, right: 8, bottom: 16),
      child: Row(
        children: [
          IconButton(
            tooltip: '我的',
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
            onPressed: onAccount,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: '搜索',
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HmAppbar oldDelegate) =>
      oldDelegate.topPadding != topPadding ||
      oldDelegate.title != title ||
      oldDelegate.onAccount != onAccount ||
      oldDelegate.onSearch != onSearch;
}

// // ==================== 顶部标题栏 ====================
// class HmAppbar extends StatefulWidget {
//   const HmAppbar({super.key, required this.topPadding});

//   final double topPadding;

//   @override
//   State<HmAppbar> createState() => _HmAppbarState();
// }

// class _HmAppbarState extends State<HmAppbar> {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     // 深色模式下品牌蓝压暗 25%，避免刺眼
//     final startColor = isDark
//         ? Color.lerp(AppColors.primaryBlue, Colors.black, 0.25)!
//         : AppColors.primaryBlue;
//     final endColor = isDark
//         ? Color.lerp(AppColors.primaryBlueDark, Colors.black, 0.25)!
//         : AppColors.primaryBlueDark;

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [startColor, endColor],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       padding: EdgeInsets.only(
//         top: widget.topPadding,
//         left: 8,
//         right: 8,
//         bottom: 16,
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.home_filled, color: Colors.white),
//             onPressed: () {},
//           ),
//           const Expanded(
//             child: Text(
//               '电梯工具手册集',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.white, size: 24),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
