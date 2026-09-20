import 'dart:io' show Platform;

import 'package:dio/dio.dart';

/// Dio 工厂：
/// 统一创建 HTTP 客户端，集中管理超时、基础地址与默认请求头。
class DioClient {
  const DioClient._();

  /// 后端服务端口（与 server 默认值一致）。
  static const int serverPort = 8099;

  /// API 根地址：
  ///
  /// 优先级：
  /// 1. 运行时 `--dart-define=API_BASE_URL=https://xxx` 覆盖；
  /// 2. Android 模拟器访问宿主机用 10.0.2.2；
  /// 3. 其他平台（Windows / iOS 模拟器 / 桌面）用 127.0.0.1。
  ///
  /// 真机调试时请通过 dart-define 指向宿主机局域网 IP，例如：
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8099
  static final String baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) {
      // 去掉末尾斜杠，避免拼接路径时出现 //
      return defined.endsWith('/')
          ? defined.substring(0, defined.length - 1)
          : defined;
    }

    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    return 'http://$host:$serverPort';
  }

  /// 把后端返回的相对路径（如 `/files/icon/a.png`）补成完整 URL；
  /// 已经是 http(s) 完整地址时原样返回。
  static String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return baseUrl + (path.startsWith('/') ? path : '/$path');
  }

  /// 创建一个具备默认网络配置的 Dio 实例。
  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // 连接超时：建立 TCP/SSL 连接的最长等待时间。
        connectTimeout: const Duration(seconds: 10),
        // 接收超时：服务端返回数据的最长等待时间。
        receiveTimeout: const Duration(seconds: 30),
        // 发送超时：上传请求体的最长等待时间。
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: const {'Accept': 'application/json'},
      ),
    );
  }
}
