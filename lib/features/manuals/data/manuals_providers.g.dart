// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manuals_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 手册数据仓库 Provider（常驻）：
/// 注入全局 Dio，页面通过它调用后端 API。

@ProviderFor(manualsRepository)
final manualsRepositoryProvider = ManualsRepositoryProvider._();

/// 手册数据仓库 Provider（常驻）：
/// 注入全局 Dio，页面通过它调用后端 API。

final class ManualsRepositoryProvider
    extends
        $FunctionalProvider<
          ManualsRepository,
          ManualsRepository,
          ManualsRepository
        >
    with $Provider<ManualsRepository> {
  /// 手册数据仓库 Provider（常驻）：
  /// 注入全局 Dio，页面通过它调用后端 API。
  ManualsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manualsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manualsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ManualsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ManualsRepository create(Ref ref) {
    return manualsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManualsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManualsRepository>(value),
    );
  }
}

String _$manualsRepositoryHash() => r'7b06fe8240dcb88c6b3d54a8c8d722b9a2eb594d';
