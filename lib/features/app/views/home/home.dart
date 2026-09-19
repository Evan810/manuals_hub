import 'package:flutter/material.dart';
import 'package:manuals_hub/features/app/models/home/hmcategory.dart';
import 'package:manuals_hub/features/app/models/home/until_appbar.dart';
import 'package:manuals_hub/features/app/models/home/hmwidget.dart';
import 'package:manuals_hub/features/manuals/data/manuals_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onAccountTap});

  final VoidCallback onAccountTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = const ManualsRepository();
  Map<String, int> _categories = const {};
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _repository.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _selectedCategory = categories.isEmpty ? null : categories.keys.first;
    });
  }

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
      SliverPersistentHeader(
        pinned: true,
        delegate: _HmCategoryDelegate(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onSelected: (category) =>
              setState(() => _selectedCategory = category),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      HmWidget(category: _selectedCategory),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: _getScrollChilder());
  }
}

class _HmCategoryDelegate extends SliverPersistentHeaderDelegate {
  _HmCategoryDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final Map<String, int> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;

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
      child: HmCategory(
        categories: categories,
        selectedCategory: selectedCategory,
        onSelected: onSelected,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HmCategoryDelegate oldDelegate) =>
      oldDelegate.categories != categories ||
      oldDelegate.selectedCategory != selectedCategory;
}
