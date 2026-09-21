import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manuals_hub/features/app/models/home/hmcategory.dart';
import 'package:manuals_hub/features/app/models/home/until_appbar.dart';
import 'package:manuals_hub/features/app/models/home/hmwidget.dart';
import 'package:manuals_hub/features/manuals/data/manual_providers.dart';
import 'package:manuals_hub/features/manuals/models/category.dart';

/// 锦囊妙计分类 id：该分类从首页分类栏移除，统一放到底部导航“锦囊妙计”。
const int _tipsCategoryId = 4;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.onAccountTap});

  final VoidCallback onAccountTap;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int? _selectedCategoryId;

  void _selectDefault(List<Category> categories) {
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    // 首页只展示 4 个设备品牌分类，锦囊妙计放到底部导航。
    final categories = (categoriesAsync.value ?? const <Category>[])
        .where((c) => c.categoryId != _tipsCategoryId)
        .toList(growable: false);
    _selectDefault(categories);

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: HmAppbar(
            topPadding: MediaQuery.paddingOf(context).top,
            title: '电梯工具手册集',
            onAccount: widget.onAccountTap,
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _HmCategoryDelegate(
            categories: categories,
            selectedCategoryId: _selectedCategoryId,
            onSelected: (categoryId) =>
                setState(() => _selectedCategoryId = categoryId),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        categoriesAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => SliverToBoxAdapter(
            child: _ErrorRetry(
              message: '$error',
              onRetry: () => ref.invalidate(categoriesProvider),
            ),
          ),
          data: (_) => HmWidget(categoryId: _selectedCategoryId),
        ),
      ],
    );
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
