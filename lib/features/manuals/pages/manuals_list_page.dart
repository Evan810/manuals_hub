import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

class ManualsListPage extends StatelessWidget {
  const ManualsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 本课先用假数据跑通路由，后面课程再替换成真实 API 数据。
    final articles = ['article_001', 'article_002', 'article_003'];

    return Scaffold(
      appBar: AppBar(title: const Text('新闻列表')),
      body: ListView.separated(
        itemCount: articles.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final articleId = articles[index];

          return ListTile(
            title: Text('新闻 ${index + 1}'),
            subtitle: Text('点击进入详情页：$articleId'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // push 会把详情页压入页面栈，详情页可以返回列表页。
              context.push(AppRoutes.chaptersPath(articleId));
            },
          );
        },
      ),
    );
  }
}
