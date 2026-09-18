import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/manuals/models/manuals_header.dart';

class ManualsListPage extends StatelessWidget {
  const ManualsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final manuals = [
      (
        id: 'article_001',
        title: '从这里开始使用手册中心',
        subtitle: '快速熟悉内容结构，找到解决问题的路径',
        chapterCount: 6,
      ),
      (
        id: 'article_002',
        title: '电梯运行状态与故障诊断',
        subtitle: '查看运行状态，定位常见故障原因',
        chapterCount: 8,
      ),
      (
        id: 'article_003',
        title: '参数设置与维护操作',
        subtitle: '了解参数读取、修改及维护流程',
        chapterCount: 5,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ManualsHeaderDelegate(
              topPadding: topPadding,
              title: 'xxx手册目录',
              onBack: () => context.pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.builder(
              itemCount: manuals.length,
              itemBuilder: (context, index) {
                final manual = manuals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ManualCard(
                    title: manual.title,
                    subtitle: manual.subtitle,
                    chapterCount: manual.chapterCount,
                    onTap: () =>
                        context.push(AppRoutes.chaptersPath(manual.id)),
                  ),
                );
              },
            ),
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
