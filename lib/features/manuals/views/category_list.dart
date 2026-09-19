import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/core.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/manuals/models/manuals_header.dart';
import 'package:manuals_hub/features/manuals/data/manuals_repository.dart';
import 'package:manuals_hub/features/manuals/models/manual.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key, this.category});

  final String? category;

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final _repository = const ManualsRepository();

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
              title: '${widget.category ?? '全部'}手册目录',
              onBack: () => context.pop(),
            ),
          ),
          FutureBuilder<List<Manual>>(
            future: widget.category == null
                ? Future.value(const <Manual>[])
                : _repository.getManualsByCategory(widget.category!),
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
                    child: Text('手册数据库加载失败：${snapshot.error}'),
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
                        subtitle: '手册路径：${manual.path}/${manual.entry}',
                        chapterCount: manual.chapterCount,
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
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int chapterCount;
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
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
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
                      subtitle,
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                    const SizedBox(height: 6),
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
