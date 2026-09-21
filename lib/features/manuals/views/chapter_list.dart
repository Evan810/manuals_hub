import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/core.dart';
import 'package:manuals_hub/features/manuals/data/manual_providers.dart';
import 'package:manuals_hub/features/manuals/models/manuals_header.dart';

/// 手册章节列表页：通过 manual_id 读取本地章节（一次查询，结果由 Provider 缓存）。
class ChapterPage extends ConsumerWidget {
  const ChapterPage({super.key, required this.args});

  // id 是 manual_id（来自 URL），title 来自 query/extra。
  final ChapterArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final manualId = int.tryParse(args.id) ?? 0;
    final chaptersAsync = ref.watch(chaptersByManualProvider(manualId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ManualsHeaderDelegate(
              topPadding: topPadding,
              title: args.title,
              onBack: () => context.pop(),
            ),
          ),
          chaptersAsync.when(
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
                    Text('章节加载失败：$error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          ref.invalidate(chaptersByManualProvider(manualId)),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
            data: (chapters) {
              if (chapters.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('该手册暂无章节')),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList.builder(
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _ChapterCard(
                        title: chapter.title,
                        onTap: () => context.push(
                          AppRoutes.localManualPath(
                            manualId,
                            // html_path 缺省时阅读页会用手册默认入口兜底。
                            entryRelative: chapter.htmlPath,
                            anchor: chapter.isReader
                                ? 'p${chapter.pageStart}'
                                : null,
                            title: chapter.title,
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

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.title, required this.onTap});

  final String title;
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
              // const Icon(Icons.menu_book_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
