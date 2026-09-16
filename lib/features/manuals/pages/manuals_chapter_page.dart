import 'package:flutter/material.dart';

class ManualsChapterPage extends StatelessWidget {
  const ManualsChapterPage({super.key, required this.manualsId});

  // 从路由参数中传进来的新闻 id。
  final String manualsId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手册章节目录')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('当前新闻 ID'),
            const SizedBox(height: 8),
            SelectableText(
              manualsId,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('返回列表'),
            ),
          ],
        ),
      ),
    );
  }
}
