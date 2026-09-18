import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/theme_mode_provider.dart';
import 'package:manuals_hub/features/app/providers/account_provider.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final account = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '返回',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('应用设置'),
      ),
      body: ListView(
        children: [
          _SettingsGroup(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('主题设置'),
                subtitle: Text(_themeLabel(themeMode)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showThemePicker(context, ref, themeMode),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up_outlined),
                title: const Text('语音设置'),
                subtitle: const Text('控制应用中的语音提示'),
                value: account.voiceEnabled,
                onChanged: ref.read(accountProvider.notifier).toggleVoice,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('版本信息'),
                subtitle: Text('Manuals Hub 0.1.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('免责声明'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppRoutes.disclaimer),
              ),
              ListTile(
                leading: const Icon(Icons.apps_outlined),
                title: const Text('关于应用'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppRoutes.about),
              ),
            ],
          ),
          if (account.isLoggedIn)
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton(
                onPressed: ref.read(accountProvider.notifier).signOut,
                child: const Text('退出登录'),
              ),
            ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => '跟随系统',
      ThemeMode.light => '浅色模式',
      ThemeMode.dark => '深色模式',
    };
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return ListTile(
              leading: Icon(
                mode == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: mode == current
                    ? Theme.of(sheetContext).colorScheme.primary
                    : null,
              ),
              title: Text(_themeLabel(mode)),
              onTap: () {
                ref.read(themeModeProvider.notifier).setMode(mode);
                Navigator.pop(sheetContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: children
            .map(
              (child) => Material(
                color: Theme.of(context).colorScheme.surface,
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}
