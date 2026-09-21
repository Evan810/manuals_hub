import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/core.dart';
import 'package:manuals_hub/features/manuals/data/manual_providers.dart';
import 'package:manuals_hub/features/manuals/models/manuals_header.dart';

/// 分类下的手册列表页：按 categoryId 读取本地手册（Provider 缓存）。
class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key, this.categoryId, this.title});

  final int? categoryId;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final id = categoryId;
    final manualsAsync = id == null
        ? null
        : ref.watch(manualsByCategoryProvider(id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ManualsHeaderDelegate(
              topPadding: topPadding,
              title: '${title ?? '全部'}手册目录',
              onBack: () => context.pop(),
            ),
          ),
          if (id == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('缺少分类参数，无法展示手册列表')),
              ),
            )
          else
            manualsAsync!.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('手册加载失败：$error', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.invalidate(manualsByCategoryProvider(id)),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (manuals) {
                if (manuals.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('该分类暂无手册')),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: manuals.length,
                    itemBuilder: (context, index) {
                      final manual = manuals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ManualCard(
                          title: manual.title,
                          chapterCount: manual.chapterCount,
                          iconPath: manual.localIconPath,
                          category: manual.category,
                          bundled: manual.bundled,
                          onTap: () => context.push(
                            AppRoutes.localManualPath(
                              manual.id,
                              title: manual.title,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ManualCard extends StatelessWidget {
  const _ManualCard({
    required this.title,
    required this.chapterCount,
    required this.iconPath,
    required this.category,
    required this.bundled,
    required this.onTap,
  });

  final String title;
  final int chapterCount;
  final String? iconPath;
  final String category;
  final bool bundled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryText = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: iconPath != null
                    ? Image.asset(
                        iconPath!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$chapterCount 个章节',
                          style: TextStyle(fontSize: 12, color: secondaryText),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          bundled
                              ? Icons.download_done_rounded
                              : Icons.cloud_outlined,
                          size: 13,
                          color: secondaryText,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          bundled ? '已内置' : '按需下载',
                          style: TextStyle(fontSize: 11, color: secondaryText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
