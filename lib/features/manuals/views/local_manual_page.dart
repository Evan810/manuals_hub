import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/network/local_asset_server.dart';
import '../data/manual_providers.dart';
import '../data/packs/pack_models.dart';
import '../models/manual.dart';

/// 手册 HTML 阅读页。
///
/// 资源来源对页面透明：内置手册走 rootBundle，按需手册走已下载资源包，
/// 统一由 [LocalAssetServer]（http://127.0.0.1）提供，HTML 内相对路径
/// 的图片/CSS/JS 均可正常加载。非内置且未下载时先展示下载闸门。
class LocalManualPage extends ConsumerStatefulWidget {
  const LocalManualPage({
    super.key,
    required this.manualId,
    required this.title,
    this.entryRelative,
    this.anchor,
  });

  final int manualId;
  final String title;

  /// 手册根目录内的相对文件（如某章节 html_path）；null 取手册默认入口。
  final String? entryRelative;
  final String? anchor;

  @override
  ConsumerState<LocalManualPage> createState() => _LocalManualPageState();
}

class _LocalManualPageState extends ConsumerState<LocalManualPage> {
  @override
  Widget build(BuildContext context) {
    final manualAsync = ref.watch(manualProvider(widget.manualId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: manualAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorPane(
          message: '手册信息加载失败：$error',
          onRetry: () => ref.invalidate(manualProvider(widget.manualId)),
        ),
        data: (manual) => _buildManualBody(context, manual),
      ),
    );
  }

  Widget _buildManualBody(BuildContext context, Manual manual) {
    final packManager = ref.watch(packManagerProvider);
    if (manual.bundled) {
      return _ManualWebViewer(url: _entryUrl(manual), anchor: widget.anchor);
    }

    return AnimatedBuilder(
      animation: packManager,
      builder: (context, _) {
        final state = packManager.stateFor(manual.id);
        if (state.status == PackStatus.ready) {
          return _ManualWebViewer(
            url: _entryUrl(manual),
            anchor: widget.anchor,
          );
        }
        return _DownloadGate(
          manual: manual,
          state: state,
          onDownload: () => _startDownload(manual),
        );
      },
    );
  }

  String _entryUrl(Manual manual) {
    final relative =
        (widget.entryRelative == null || widget.entryRelative!.isEmpty)
        ? manual.entry
        : widget.entryRelative!;
    return LocalAssetServer.instance.urlFor(
      manual.categoryId,
      manual.path,
      relative,
    );
  }

  Future<void> _startDownload(Manual manual) async {
    final packManager = ref.read(packManagerProvider);
    try {
      // 首次进入需先拿到清单（失败状态会写入 PackEntryState）。
      await packManager.loadManifest();
      await packManager.ensureInstalled(manual.id);
    } catch (_) {
      // 错误已通过 manager 状态体现，UI（AnimatedBuilder）负责渲染。
    }
  }
}

/// 非内置手册的下载闸门：大小提示、进度、错误重试。
class _DownloadGate extends StatelessWidget {
  const _DownloadGate({
    required this.manual,
    required this.state,
    required this.onDownload,
  });

  final Manual manual;
  final PackEntryState state;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloading = state.status == PackStatus.downloading;
    final sizeBytes = state.info?.packedSize ?? 0;
    final sizeLabel = sizeBytes > 0
        ? '约 ${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB'
        : '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_download_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              manual.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '该手册未随安装包内置，需要联网下载后离线阅读。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            if (sizeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(sizeLabel, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 22),
            if (downloading)
              SizedBox(
                width: 240,
                child: Column(
                  children: [
                    LinearProgressIndicator(value: state.progress.clamp(0, 1)),
                    const SizedBox(height: 8),
                    Text(
                      '${(state.progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              )
            else
              FilledButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded),
                label: const Text('下载手册'),
              ),
            if (state.status == PackStatus.error && state.error != null) ...[
              const SizedBox(height: 14),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 本地手册 WebView：仅允许 loopback 站内导航，外链一律拦截。
class _ManualWebViewer extends StatefulWidget {
  const _ManualWebViewer({required this.url, this.anchor});

  final String url;
  final String? anchor;

  @override
  State<_ManualWebViewer> createState() => _ManualWebViewerState();
}

class _ManualWebViewerState extends State<_ManualWebViewer> {
  late final WebViewController _controller;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final uri = widget.anchor == null || widget.anchor!.isEmpty
        ? Uri.parse(widget.url)
        : Uri.parse('${widget.url}#${Uri.encodeComponent(widget.anchor!)}');

    _controller = WebViewController()
      // 手册 HTML 依赖本地脚本（jQuery Mobile 等），对本地可信内容启用 JS。
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // 只允许本机资源服务器；外部 http(s)/文件 scheme 一律拦截，
            // 避免手册内容把 WebView 带到任意外部站点。
            final host = Uri.tryParse(request.url)?.host;
            final isLoopback = host == '127.0.0.1' || host == 'localhost';
            if (isLoopback) return NavigationDecision.navigate;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('已拦截外部链接'),
                duration: Duration(seconds: 1),
              ),
            );
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _error = error.description);
            }
          },
        ),
      )
      ..loadRequest(uri).catchError((Object error) {
        if (mounted) setState(() => _error = '$error');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading && _error == null)
          const Center(child: CircularProgressIndicator()),
        if (_error != null) _ErrorPane(message: '手册打开失败：$_error'),
      ],
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}
