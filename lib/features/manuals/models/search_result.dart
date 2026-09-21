import 'package:manuals_hub/core/network/dio_client.dart';
import 'package:manuals_hub/features/manuals/models/manual.dart';

/// 品牌搜索结果。
class BrandResult {
  const BrandResult({
    required this.fp09,
    required this.brand,
    required this.manualId,
  });

  /// FP09 代码（可能与关键字精确相等）。
  final String fp09;

  final String brand;

  /// 关联手册 id。
  final int manualId;

  factory BrandResult.fromJson(Map<String, Object?> json) {
    return BrandResult(
      fp09: json['fp09'] as String,
      brand: json['brand'] as String,
      manualId: json['manual_id'] as int,
    );
  }
}

/// 章节搜索结果（比 Chapter 多了所属手册标题）。
class ChapterSearchResult {
  const ChapterSearchResult({
    required this.chapterId,
    required this.manualId,
    required this.manualTitle,
    required this.chapterNo,
    required this.title,
    this.entryUrl,
  });

  final int chapterId;
  final int manualId;
  final String manualTitle;
  final int chapterNo;
  final String title;
  final String? entryUrl;

  factory ChapterSearchResult.fromJson(Map<String, Object?> json) {
    final entryUrl = json['entry_url'] as String?;
    return ChapterSearchResult(
      chapterId: json['chapter_id'] as int,
      manualId: json['manual_id'] as int,
      manualTitle: json['manual_title'] as String,
      chapterNo: json['chapter_no'] as int,
      title: json['title'] as String,
      entryUrl: entryUrl == null ? null : DioClient.resolveUrl(entryUrl),
    );
  }
}

/// `/api/search` 的整体响应：品牌 + 手册 + 章节三类结果。
class SearchResult {
  const SearchResult({
    required this.keyword,
    required this.brands,
    required this.manuals,
    required this.chapters,
  });

  final String keyword;
  final List<BrandResult> brands;
  final List<Manual> manuals;
  final List<ChapterSearchResult> chapters;

  /// 是否三类结果全部为空。
  bool get isEmpty => brands.isEmpty && manuals.isEmpty && chapters.isEmpty;

  factory SearchResult.fromJson(Map<String, Object?> json) {
    return SearchResult(
      keyword: json['keyword'] as String,
      brands: (json['brands'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(BrandResult.fromJson)
          .toList(),
      manuals: (json['manuals'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Manual.fromJson)
          .toList(),
      chapters: (json['chapters'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ChapterSearchResult.fromJson)
          .toList(),
    );
  }
}
