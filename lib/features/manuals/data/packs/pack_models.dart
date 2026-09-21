/// 按需下载资源包清单模型，对应后端 GET /api/packs（由 assets/build_packs.py 生成）。
library;

class PackInfo {
  const PackInfo({
    required this.manualId,
    required this.title,
    required this.categoryId,
    required this.category,
    required this.path,
    required this.entry,
    required this.icon,
    required this.fileCount,
    required this.sizeBytes,
    required this.packedSize,
    required this.sha256,
    required this.url,
  });

  factory PackInfo.fromJson(Map<String, dynamic> json) {
    return PackInfo(
      manualId: json['manual_id'] as int,
      title: json['title'] as String? ?? '',
      categoryId: json['category_id'] as int,
      category: json['category'] as String? ?? '',
      path: json['path'] as String? ?? '',
      entry: (json['entry'] as String?) ?? 'index.html',
      icon: (json['icon'] as String?) ?? '',
      fileCount: (json['file_count'] as int?) ?? 0,
      sizeBytes: (json['size_bytes'] as int?) ?? 0,
      packedSize: (json['packed_size'] as int?) ?? 0,
      sha256: (json['sha256'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
    );
  }

  final int manualId;
  final String title;
  final int categoryId;
  final String category;

  /// 手册在资源目录下的相对目录名（与 assets/{category_id}/{path} 一致）。
  final String path;
  final String entry;
  final String icon;
  final int fileCount;
  final int sizeBytes;
  final int packedSize;
  final String sha256;

  /// 相对下载地址，如 /packs/1/some_manual.zip
  final String url;

  Map<String, dynamic> toJson() => {
    'manual_id': manualId,
    'title': title,
    'category_id': categoryId,
    'category': category,
    'path': path,
    'entry': entry,
    'icon': icon,
    'file_count': fileCount,
    'size_bytes': sizeBytes,
    'packed_size': packedSize,
    'sha256': sha256,
    'url': url,
  };
}

class PackManifest {
  const PackManifest({required this.generated, required this.packs});

  factory PackManifest.fromJson(Map<String, dynamic> json) {
    final raw = (json['packs'] as List?) ?? const [];
    return PackManifest(
      generated: (json['generated'] as String?) ?? '',
      packs: [
        for (final item in raw)
          PackInfo.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }

  final String generated;
  final List<PackInfo> packs;

  PackInfo? forManual(int manualId) {
    for (final pack in packs) {
      if (pack.manualId == manualId) return pack;
    }
    return null;
  }
}

/// 单个资源包在 App 内的安装/下载状态。
enum PackStatus {
  /// 清单中不存在该包（内置手册无需下载）。
  notNeeded,

  /// 未下载。
  absent,

  /// 下载中。
  downloading,

  /// 已下载、校验通过并解压完成。
  ready,

  /// 下载/校验/解压失败，可重试。
  error,
}

class PackEntryState {
  const PackEntryState({
    this.status = PackStatus.absent,
    this.progress = 0,
    this.info,
    this.error,
    this.hasUpdate = false,
  });

  final PackStatus status;

  /// 下载进度 0~1。
  final double progress;
  final PackInfo? info;
  final String? error;

  /// 已安装旧版本但清单中有新版本（旧版本仍可正常阅读）。
  final bool hasUpdate;

  PackEntryState copyWith({
    PackStatus? status,
    double? progress,
    PackInfo? info,
    String? error,
    bool? hasUpdate,
  }) {
    return PackEntryState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      info: info ?? this.info,
      error: error,
      hasUpdate: hasUpdate ?? this.hasUpdate,
    );
  }
}
