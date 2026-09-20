import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/core.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/manuals/data/manuals_providers.dart';
import 'package:manuals_hub/features/manuals/models/manual.dart';
import 'package:manuals_hub/features/manuals/models/manuals_header.dart';

/// 分类下的手册列表页：按 categoryId 拉取手册。
class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({super.key, this.categoryId, this.title});

  final int? categoryId;
  final String? title;

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage> {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ManualsHeaderDelegate(
              topPadding: topPadding,
              title: '${widget.title ?? '全部'}手册目录',
              onBack: () => context.pop(),
            ),
          ),
          FutureBuilder<List<Manual>>(
            future: widget.categoryId == null
                ? Future.value(const <Manual>[])
                : ref.read(manualsRepositoryProvider).getManuals(
                      widget.categoryId!,
                    ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('手册加载失败：${snapshot.error}'),
                  ),
                );
              }
              final manuals = snapshot.data ?? const <Manual>[];
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
                        subtitle: manual.entryUrl ?? '',
                        chapterCount: manual.chapterCount,
                        iconPath: manual.localIconPath,
                        category: manual.category,
                        onTap: () => context.push(
                          AppRoutes.chaptersPath('${manual.id}'),
                          extra: ChapterArgs(
                            id: '${manual.id}',
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
    required this.subtitle,
    required this.chapterCount,
    required this.iconPath,
    required this.category,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int chapterCount;
  final String? iconPath;
  final String category;
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
                    Text(
                      '$chapterCount 个章节',
                      style: TextStyle(fontSize: 12, color: secondaryText),
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
