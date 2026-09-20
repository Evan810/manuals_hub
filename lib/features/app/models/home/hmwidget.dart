import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/manuals/data/manuals_providers.dart';
import 'package:manuals_hub/features/manuals/models/manual.dart';

/// 首页手册列表：按选中的 categoryId 加载该分类下的手册。
class HmWidget extends ConsumerWidget {
  const HmWidget({super.key, required this.categoryId});

  final int? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = theme.dividerColor;
    final primaryText =
        theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final secondaryText =
        theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant;

    if (categoryId == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return FutureBuilder<List<Manual>>(
      future: ref.read(manualsRepositoryProvider).getManuals(categoryId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _Message(text: '手册加载失败：${snapshot.error}'),
          );
        }
        final manuals = snapshot.data ?? const <Manual>[];
        if (manuals.isEmpty) {
          return const SliverToBoxAdapter(
            child: _Message(text: '该分类暂无手册'),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList.builder(
            itemCount: manuals.length,
            itemBuilder: (context, index) {
              final manual = manuals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push(
                      AppRoutes.chaptersPath('${manual.id}'),
                      extra: ChapterArgs(
                        id: '${manual.id}',
                        title: manual.title,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          _buildIconBadge(manual),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  manual.title,
                                  style: TextStyle(
                                    color: primaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${manual.chapterCount} 个章节',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: secondaryText,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildIconBadge(Manual manual) {
    return Container(
      width: 44,
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      // 优先使用本地打包图标；无本地图标时回退为分类名文字
      child: manual.localIconPath != null
          ? Image.asset(
              manual.localIconPath!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Text(
                manual.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Text(
              manual.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(text)),
    );
  }
}
