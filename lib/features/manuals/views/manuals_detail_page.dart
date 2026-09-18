import 'package:flutter/material.dart';

class ManualsDetailPage extends StatelessWidget {
  const ManualsDetailPage({super.key, required this.manualsId});

  final String manualsId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手册章节目录')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('当前手册 ID'),
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
