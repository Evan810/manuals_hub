import 'package:flutter/material.dart';
import 'package:manuals_hub/features/app/models/home/hmcategory.dart';
import 'package:manuals_hub/features/app/models/home/until_appbar.dart';
import 'package:manuals_hub/features/app/models/home/hmwidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onAccountTap});

  final VoidCallback onAccountTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _getScrollChilder() {
    final topPadding = MediaQuery.paddingOf(context).top;

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: HmAppbar(
          topPadding: topPadding,
          title: '电梯工具手册集',
          onAccount: widget.onAccountTap,
        ),
      ),
      SliverPersistentHeader(pinned: true, delegate: _HmCategoryDelegate()),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      HmWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: _getScrollChilder());
  }
}

class _HmCategoryDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 40;

  @override
  double get maxExtent => 40;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const HmCategory(),
    );
  }

  @override
  bool shouldRebuild(covariant _HmCategoryDelegate oldDelegate) => false;
}
