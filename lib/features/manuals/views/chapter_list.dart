import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/features/manuals/models/manuals_header.dart';

class ManualsChapterPage extends StatelessWidget {
  const ManualsChapterPage({super.key, required this.manualsId});

  // 从路由参数中传进来的新闻 id。
  final String manualsId;

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
              title: "手册-$manualsId",
              onBack: () => context.pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.list(
              children: [
                _ChapterCard(title: '当前手册', onTap: () {}),
                _ChapterCard(title: '第一章：基础介绍', onTap: () {}),
                _ChapterCard(title: '第二章：运行状态', onTap: () {}),
                _ChapterCard(title: '第三章：故障处理', onTap: () {}),
              ],
            ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
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
                const Icon(Icons.menu_book_rounded, color: Colors.blue),
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
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
