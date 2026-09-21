import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manuals_hub/core/router/app_routes.dart';

import '../data/manual_providers.dart';
import 'local_manual_page.dart';

/// 章节内容页：使用 WebView 浏览章节 HTML，不再直接渲染图片列表。
/// 直接打开章节的 html_path。底层复用 [LocalManualPage]：内置/已下载资源
/// 由本机资源服务器统一提供，未下载的按需手册会先显示下载闸门。
class ManualsDetailPage extends ConsumerWidget {
  const ManualsDetailPage({super.key, required this.args});

  final ChapterDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersByManualProvider(args.manualId));

    return chaptersAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(args.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(args.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('章节加载失败：$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(chaptersByManualProvider(args.manualId)),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (chapters) {
        final chapter = chapters.firstWhere(
          (c) => c.id == args.chapterId,
          orElse: () => throw StateError('章节不存在：${args.chapterId}'),
        );
        return LocalManualPage(
          manualId: args.manualId,
          title: chapter.title,
          entryRelative: chapter.htmlPath,
        );
      },
    );
  }
}
