import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

// ==================== 顶部标题栏 ====================
class HmAppbar extends StatefulWidget {
  const HmAppbar({super.key, required this.topPadding});

  final double topPadding;

  @override
  State<HmAppbar> createState() => _HmAppbarState();
}

class _HmAppbarState extends State<HmAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(
        top: widget.topPadding,
        left: 8,
        right: 8,
        bottom: 16,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home_filled, color: Colors.white),
            onPressed: () {},
          ),
          const Expanded(
            child: Text(
              '电梯工具手册集',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
