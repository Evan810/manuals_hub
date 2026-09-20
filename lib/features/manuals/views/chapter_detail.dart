import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';

import '../data/manuals_providers.dart';
import '../models/chapter_image.dart';
import '../models/manuals_header.dart';

/// 章节内容页：通过 manual_id + chapter_id 拉取图片（API 3）。
///
/// 使用 [CachedNetworkImage] 实现首次加载后自动缓存到本地文件系统，
/// 二次打开秒开，离线也能看。
class ManualsDetailPage extends ConsumerWidget {
  const ManualsDetailPage({super.key, required this.args});

  final ChapterDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;

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
          FutureBuilder<ChapterImages>(
            future: ref.read(manualsRepositoryProvider).getChapterImages(
                  args.manualId,
                  args.chapterId,
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('图片加载失败：${snapshot.error}'),
                  ),
                );
              }

              final images = snapshot.data?.images ?? const <ChapterImage>[];
              if (images.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('该章节暂无图片')),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                sliver: SliverList.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: image.url,
                          fit: BoxFit.fitWidth,
                          // 首次加载时的占位
                          placeholder: (_, _) => Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                          // 加载失败的兜底
                          errorWidget: (_, _, _) => Container(
                            height: 120,
                            alignment: Alignment.center,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Text('图片加载失败'),
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
