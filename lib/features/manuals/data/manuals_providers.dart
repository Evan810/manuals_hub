import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/dio_provider.dart';
import 'manuals_repository.dart';

part 'manuals_providers.g.dart';

/// 手册数据仓库 Provider（常驻）：
/// 注入全局 Dio，页面通过它调用后端 API。
@Riverpod(keepAlive: true)
ManualsRepository manualsRepository(Ref ref) {
  return ManualsRepository(ref.watch(dioProvider));
}
