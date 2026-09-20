import 'package:manuals_hub/core/network/dio_client.dart';

/// 章节内的一张图片。
///
/// 对应接口：`GET /api/manuals/{manual_id}/chapters/{chapter_id}/images`
class ChapterImage {
  const ChapterImage({
    required this.sortOrder,
    required this.path,
    required this.url,
  });

  /// 图片在章节内的顺序。
  final int sortOrder;

  /// 图片相对路径。
  final String path;

  /// 图片完整地址（可直接用于 Image.network）。
  final String url;

  factory ChapterImage.fromJson(Map<String, Object?> json) {
    return ChapterImage(
      sortOrder: json['sort_order'] as int,
      path: json['path'] as String,
      url: DioClient.resolveUrl(json['url'] as String),
    );
  }
}

/// 章节图片接口的整体响应。
class ChapterImages {
  const ChapterImages({
    required this.manualId,
    required this.chapterId,
    required this.images,
  });

  final int manualId;
  final int chapterId;
  final List<ChapterImage> images;

  factory ChapterImages.fromJson(Map<String, Object?> json) {
    return ChapterImages(
      manualId: json['manual_id'] as int,
      chapterId: json['chapter_id'] as int,
      images: (json['images'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ChapterImage.fromJson)
          .toList(),
    );
  }
}
