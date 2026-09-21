/// 手册数据层 Riverpod Provider（本地优先）：
/// - 数据库初始化、资源包管理器、本机资源服务器在启动时一次性就绪；
/// - 分类 / 手册 / 章节均走 family FutureProvider，由 Riverpod 缓存，
///   替代 build 中直接 new Future 的 FutureBuilder，避免重建重复查询；
/// - UI 用 AsyncValue 的 loading/error 统一渲染与重试（invalidate）。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/local_asset_server.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../models/category.dart';
import '../models/chapter.dart';
import '../models/manual.dart';
import 'local_manual_repository.dart';
import 'packs/pack_manager.dart';

final localManualRepositoryProvider = Provider<LocalManualRepository>((ref) {
  return LocalManualRepository.instance;
});

/// 资源包下载管理器（单例，内部为 ChangeNotifier，UI 用 AnimatedBuilder 订阅）。
final packManagerProvider = Provider<PackManager>((ref) {
  return PackManager(
    dio: ref.watch(dioProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

/// 本地数据链路就绪：复制/升级内置数据库 → 初始化资源包管理器 →
/// 启动本机资源服务器（内置 asset + 已下载资源包统一来源）。
final localDataReadyProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(localManualRepositoryProvider);
  await repository.initialize();

  final packManager = ref.watch(packManagerProvider);
  await packManager.initialize();
  await LocalAssetServer.instance.start(packFileResolver: packManager.packFile);

  // 后台对账资源包清单（发现新版本；离线/服务不可用时静默跳过，不阻塞启动）。
  unawaited(packManager.loadManifest().then<void>((_) {}, onError: (_) {}));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  ref.watch(localDataReadyProvider).requireValue;
  return ref.watch(localManualRepositoryProvider).getCategories();
});

final manualsByCategoryProvider = FutureProvider.family<List<Manual>, int>((
  ref,
  categoryId,
) async {
  ref.watch(localDataReadyProvider).requireValue;
  return ref.watch(localManualRepositoryProvider).getManuals(categoryId);
});

final manualProvider = FutureProvider.family<Manual, int>((
  ref,
  manualId,
) async {
  ref.watch(localDataReadyProvider).requireValue;
  return ref.watch(localManualRepositoryProvider).getManual(manualId);
});

final chaptersByManualProvider = FutureProvider.family<List<Chapter>, int>((
  ref,
  manualId,
) async {
  ref.watch(localDataReadyProvider).requireValue;
  return ref.watch(localManualRepositoryProvider).getChapters(manualId);
});
