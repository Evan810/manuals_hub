/// 本机资源 HTTP 服务器：统一对外暴露两类手册资源
///
/// 1. 内置手册：rootBundle 中的 Flutter asset
/// 2. 已下载资源包：应用目录 manual_packs/ 下解压的文件
///
/// WebView 无论资源来自哪种渠道，都访问
/// `http://127.0.0.1:<port>/m/<categoryId>/<manualRoot>/<相对路径>`
/// 从而让手册 HTML 内的相对路径（图片/CSS/JS）自然生效。
///
/// 只绑定 loopback，外部设备无法访问。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

typedef PackFileResolver = File? Function(
  int categoryId,
  String manualRoot,
  List<String> rest,
);

class LocalAssetServer {
  LocalAssetServer._();

  static final LocalAssetServer instance = LocalAssetServer._();

  int? _port;

  /// 解析已下载资源包中的真实文件。
  PackFileResolver? _packFileResolver;

  /// 当前监听端口（未启动时为 null）。
  int? get port => _port;

  Future<int> start({PackFileResolver? packFileResolver}) async {
    final current = _port;
    if (current != null) return current;
    _packFileResolver = packFileResolver;

    final handler = const Pipeline()
        .addMiddleware(_securityHeaders)
        .addHandler(_handleRequest);

    final server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      0,
    );
    _port = server.port;
    return _port!;
  }

  /// 构造手册内某个文件的本机 URL。
  /// [relative] 相对手册根目录，如 index.html / reader.html / html/001/pages/3.jpg
  String urlFor(int categoryId, String manualRoot, String relative) {
    final base = '/m/$categoryId/$manualRoot';
    final normalized = relative.replaceAll(RegExp(r'^/+'), '');
    final path = normalized.isEmpty ? base : '$base/$normalized';
    return 'http://127.0.0.1:$_port$path';
  }

  Future<Response> _handleRequest(Request request) async {
    final rawPath = request.url.path;
    final segments = rawPath
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    if (segments.length < 3 || segments.first != 'm') {
      return _notFound();
    }
    final categoryId = int.tryParse(segments[1]);
    final manualRoot = segments[2];
    final rest = segments.sublist(3);
    if (categoryId == null ||
        categoryId < 0 ||
        rest.any((s) => s == '..' || s.contains('\\'))) {
      return _forbidden();
    }

    // 1) 已下载资源包优先（文件系统）。
    final packFile = _packFileResolver?.call(categoryId, manualRoot, rest);
    if (packFile != null && packFile.existsSync()) {
      return _fileResponse(packFile);
    }

    // 2) 回退到内置 asset。
    final assetKey = 'assets/$categoryId/$manualRoot/${rest.join('/')}';
    try {
      final data = (await rootBundle.load(assetKey)).buffer.asUint8List();
      return _bytesResponse(data, assetKey);
    } catch (_) {
      return _notFound();
    }
  }

  Response _fileResponse(File file) {
    final data = file.readAsBytesSync();
    return _bytesResponse(data, file.path);
  }

  Response _bytesResponse(Uint8List data, String pathOrKey) {
    final contentType =
        lookupMimeType(pathOrKey, headerBytes: data.take(16).toList()) ??
        'application/octet-stream';
    return Response.ok(
      data,
      headers: {
        HttpHeaders.contentTypeHeader: contentType,
        HttpHeaders.contentLengthHeader: data.length.toString(),
      },
    );
  }

  Response _notFound() => Response.notFound('not found');
  Response _forbidden() => Response.forbidden('forbidden');

  static Middleware get _securityHeaders =>
      (Handler innerHandler) => (Request request) async {
        final response = await innerHandler(request);
        return response.change(
          headers: {
            // 手册内容均为本地可信资源，禁止其被当作外部框架嵌入。
            'X-Content-Type-Options': 'nosniff',
          },
        );
      };
}
