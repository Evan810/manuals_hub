import 'package:flutter/material.dart';
import 'package:manuals_hub/features/app/models/HmCategory.dart';
import 'package:manuals_hub/features/app/models/HmAppbar.dart';
import 'package:manuals_hub/features/app/models/HmWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _getScrollChilder() {
    final topPadding = MediaQuery.paddingOf(context).top;

    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _HmAppbarDelegate(topPadding: topPadding),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      HmWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: _getScrollChilder());
  }
}

class _HmAppbarDelegate extends SliverPersistentHeaderDelegate {
  _HmAppbarDelegate({required this.topPadding});

  final double topPadding;

  @override
  double get minExtent => topPadding + 64 + 40;

  @override
  double get maxExtent => topPadding + 64 + 40;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          HmAppbar(topPadding: topPadding),          
          const HmCategory(),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HmAppbarDelegate oldDelegate) =>
      oldDelegate.topPadding != topPadding;
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return ListView(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
//       children: [
//         SearchBar(
//           hintText: '搜索手册、章节或关键词',
//           leading: const Icon(Icons.search_rounded),
//           trailing: [
//             IconButton(
//               tooltip: '打开手册',
//               onPressed: () => context.push(AppRoutes.manuals),
//               icon: const Icon(Icons.arrow_forward_rounded),
//             ),
//           ],
//           onTap: () => context.push(AppRoutes.manuals),
//         ),
//         const SizedBox(height: 24),
//         _SectionHeader(
//           title: '今日推荐',
//           actionLabel: '查看全部',
//           onAction: () => context.push(AppRoutes.manuals),
//         ),
//         const SizedBox(height: 12),
//         _FeaturedManualCard(
//           title: '从这里开始使用手册中心',
//           subtitle: '快速熟悉内容结构，找到解决问题的路径',
//           icon: Icons.auto_stories_rounded,
//           onTap: () => context.push(AppRoutes.manuals),
//         ),
//         const SizedBox(height: 24),
//         const _SectionHeader(title: '常用入口'),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _QuickAction(
//                 icon: Icons.menu_book_rounded,
//                 label: '全部手册',
//                 onTap: () => context.push(AppRoutes.manuals),
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: _QuickAction(
//                 icon: Icons.bookmark_outline_rounded,
//                 label: '我的收藏',
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: _QuickAction(icon: Icons.history_rounded, label: '最近阅读'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   const _SectionHeader({required this.title, this.actionLabel, this.onAction});

//   final String title;
//   final String? actionLabel;
//   final VoidCallback? onAction;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: Theme.of(context).textTheme.titleMedium
//               ?.copyWith(fontWeight: FontWeight.w800),
//         ),
//         if (actionLabel != null)
//           TextButton(onPressed: onAction, child: Text(actionLabel!)),
//       ],
//     );
//   }
// }

// class _FeaturedManualCard extends StatelessWidget {
//   const _FeaturedManualCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//   });

//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Card(
//       margin: EdgeInsets.zero,
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 28,
//                 backgroundColor: colorScheme.primaryContainer,
//                 child: Icon(icon, color: colorScheme.onPrimaryContainer),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       subtitle,
//                       style: TextStyle(color: colorScheme.onSurfaceVariant),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right_rounded),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _QuickAction extends StatelessWidget {
//   const _QuickAction({required this.icon, required this.label, this.onTap});

//   final IconData icon;
//   final String label;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Card(
//       margin: EdgeInsets.zero,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
//           child: Column(
//             children: [
//               Icon(icon, color: colorScheme.primary),
//               const SizedBox(height: 8),
//               Text(label, textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
