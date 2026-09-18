import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

class ManualsHeaderDelegate extends SliverPersistentHeaderDelegate {
  ManualsHeaderDelegate({
    required this.topPadding,
    required this.title,
    required this.onBack,
    this.onSearch,
  });

  final double topPadding;
  final String title;
  final VoidCallback onBack;
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(top: topPadding, left: 8, right: 8, bottom: 16),
      child: Row(
        children: [
          IconButton(
            tooltip: '返回',
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: onBack,
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
  bool shouldRebuild(covariant ManualsHeaderDelegate oldDelegate) =>
      oldDelegate.topPadding != topPadding ||
      oldDelegate.title != title ||
      oldDelegate.onBack != onBack ||
      oldDelegate.onSearch != onSearch;
}
