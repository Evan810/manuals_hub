import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/app/providers/account_provider.dart';

/// “我的”页面，负责展示账户状态和个人相关功能入口。
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 账户信息由 Provider 管理，登录状态变化时页面会自动刷新。
    final account = ref.watch(accountProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _AccountHero(
          displayName: account.displayName,
          isLoggedIn: account.isLoggedIn,
          onTap: () => _showLoginDialog(context, ref),
        ),
        const SizedBox(height: 12),
        // 常用账户和应用数据入口。
        _SettingsSection(
          children: [
            _SettingsTile(
              icon: Icons.tune_rounded,
              title: '应用设置',
              onTap: () => context.push(AppRoutes.accountSettings),
            ),
            _SettingsTile(
              icon: Icons.storage_rounded,
              title: '数据管理',
              onTap: () => _showMessage(context, '数据管理功能即将开放'),
            ),
            _SettingsTile(
              icon: Icons.bookmark_border_rounded,
              title: '我的收藏',
              onTap: () => _showMessage(context, '收藏功能即将开放'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 学习成长和扩展功能入口。
        _SettingsSection(
          children: [
            _SettingsTile(
              icon: Icons.verified_rounded,
              title: '任务成就',
              onTap: () => _showMessage(context, '任务成就功能即将开放'),
            ),
            _SettingsTile(
              icon: Icons.workspace_premium_rounded,
              title: '头像徽章',
              onTap: () => _showMessage(context, '头像徽章功能即将开放'),
            ),
            _SettingsTile(
              icon: Icons.handyman_rounded,
              title: '匠心工坊',
              onTap: () => _showMessage(context, '匠心工坊功能即将开放'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 应用说明和版权相关入口。
        _SettingsSection(
          children: [
            _SettingsTile(
              icon: Icons.feedback_rounded,
              title: '免责声明',
              onTap: () => context.push(AppRoutes.disclaimer),
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: '关于应用',
              onTap: () => context.push(AppRoutes.about),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Text(
            'Manuals Hub  ·  让知识更容易被找到',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _showLoginDialog(BuildContext context, WidgetRef ref) async {
    if (ref.read(accountProvider).isLoggedIn) return;

    // 当前使用模拟登录，后续可在此处接入真实认证流程。
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('登录/注册'),
        content: const Text('登录后可以同步收藏、阅读进度和个人资料。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('稍后'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(accountProvider.notifier).signIn();
              Navigator.pop(dialogContext);
            },
            child: const Text('模拟登录'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.displayName,
    required this.isLoggedIn,
    required this.onTap,
  });

  final String displayName;
  final bool isLoggedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 顶部账户区域根据登录状态显示不同文案和图标。
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 214,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.12),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                isLoggedIn ? Icons.person_rounded : Icons.person_add_alt_1,
                size: 54,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLoggedIn ? '欢迎回来，继续你的学习记录' : '登录后同步收藏与个人资料',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // 分组使用整行背景和上下边框，保持设置类页面的层次感。
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 可复用的设置项：左侧图标、中间标题、右侧进入箭头。
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 29),
            const SizedBox(width: 24),
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.primary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
