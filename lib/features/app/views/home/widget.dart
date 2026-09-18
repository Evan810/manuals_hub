import 'package:flutter/material.dart';
import 'package:manuals_hub/features/app/models/home/hmcategory.dart';
import 'package:manuals_hub/features/app/models/home/hmappbar.dart';
import 'package:manuals_hub/features/app/models/home/hmwidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _getScrollChilder() {
    final topPadding = MediaQuery.paddingOf(context).top;

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _HmAppbarDelegate(topPadding: topPadding),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      HmWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: _getScrollChilder());
  }
}

class _HmAppbarDelegate extends SliverPersistentHeaderDelegate {
  _HmAppbarDelegate({required this.topPadding});

  final double topPadding;

  @override
  double get minExtent => topPadding + 64 + 40;

  @override
  double get maxExtent => topPadding + 64 + 40;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          HmAppbar(topPadding: topPadding),
          const HmCategory(),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HmAppbarDelegate oldDelegate) =>
      oldDelegate.topPadding != topPadding;
}
