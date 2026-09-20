import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manuals_hub/features/app/models/home/hmcategory.dart';
import 'package:manuals_hub/features/app/models/home/until_appbar.dart';
import 'package:manuals_hub/features/app/models/home/hmwidget.dart';
import 'package:manuals_hub/features/manuals/data/manuals_providers.dart';
import 'package:manuals_hub/features/manuals/models/category.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.onAccountTap});

  final VoidCallback onAccountTap;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Category> _categories = const [];
  int? _selectedCategoryId;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories =
          await ref.read(manualsRepositoryProvider).getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategoryId = categories.isEmpty ? null : categories.first.categoryId;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
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
          selectedCategoryId: _selectedCategoryId,
          onSelected: (categoryId) =>
              setState(() => _selectedCategoryId = categoryId),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 10)),
      if (_error != null)
        SliverToBoxAdapter(
          child: _ErrorRetry(
            message: '$_error',
            onRetry: _loadCategories,
          ),
        )
      else
        HmWidget(categoryId: _selectedCategoryId),
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
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;

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
        selectedCategoryId: selectedCategoryId,
        onSelected: onSelected,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HmCategoryDelegate oldDelegate) =>
      oldDelegate.categories != categories ||
      oldDelegate.selectedCategoryId != selectedCategoryId;
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('分类加载失败：$message', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
