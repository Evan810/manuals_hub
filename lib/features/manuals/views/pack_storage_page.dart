import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/manual_providers.dart';
import '../data/packs/pack_manager.dart';
import '../data/packs/pack_models.dart';

/// 已下载手册资源包管理：查看占用、删除释放空间、检查清单更新。
class PackStoragePage extends ConsumerWidget {
  const PackStoragePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packManager = ref.watch(packManagerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '返回',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('已下载手册'),
        actions: [
          IconButton(
            tooltip: '检查更新',
            onPressed: () async {
              try {
                await packManager.loadManifest(force: true);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('已检查更新')));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('检查更新失败，请稍后重试')));
                }
              }
            },
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: packManager,
        builder: (context, _) {
          final packs = packManager.installedPacks();
          final totalBytes = packs.fold<int>(
            0,
            (sum, pack) => sum + pack.sizeBytes,
          );

          if (packs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '暂无已下载的手册。\n非内置手册会在打开时按需下载。',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.sd_storage_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '共 ${packs.length} 本，占用 ${_formatMiB(totalBytes)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: packs.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 0.5, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    final state = packManager.stateFor(pack.manualId);
                    final hasUpdate = state.hasUpdate;
                    final downloading = state.status == PackStatus.downloading;
                    return ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text(
                        pack.title.isEmpty
                            ? '手册 #${pack.manualId}'
                            : pack.title,
                      ),
                      subtitle: Text(
                        downloading
                            ? '更新中 ${(state.progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                            : '${_formatMiB(pack.sizeBytes)}'
                                  '${hasUpdate ? ' · 有新版本可更新' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasUpdate)
                            IconButton(
                              tooltip: '更新',
                              icon: downloading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: state.progress.clamp(0, 1),
                                      ),
                                    )
                                  : const Icon(Icons.system_update_rounded),
                              onPressed: downloading
                                  ? null
                                  : () async {
                                      try {
                                        await packManager.ensureInstalled(
                                          pack.manualId,
                                        );
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text('更新失败，请稍后重试'),
                                                ),
                                              );
                                        }
                                      }
                                    },
                            ),
                          IconButton(
                            tooltip: '删除',
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: downloading
                                ? null
                                : () => _confirmDelete(
                                    context,
                                    packManager,
                                    pack,
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PackManager manager,
    InstalledPackSummary pack,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除已下载手册？'),
        content: Text(
          '将释放约 ${_formatMiB(pack.sizeBytes)} 空间。'
          '下次打开该手册时需要重新下载。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) await manager.deletePack(pack.manualId);
  }

  static String _formatMiB(int bytes) {
    if (bytes <= 0) return '0 MB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
