import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '返回',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
