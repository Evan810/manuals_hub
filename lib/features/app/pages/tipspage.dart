import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/core.dart';

class TipsContent extends StatelessWidget {
  const TipsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderContent(
      icon: Icons.lightbulb_rounded,
      title: '把经验装进锦囊',
      description: '这里会汇集实用技巧、避坑指南和高效工作方法。',
      actionLabel: '浏览手册',
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(icon, size: 40, color: colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.manuals),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}