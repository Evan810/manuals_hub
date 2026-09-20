import 'package:dio/dio.dart';

import '../../../core/network/error_mapper.dart';
import '../models/category.dart';
import '../models/chapter.dart';
import '../models/chapter_image.dart';
import '../models/manual.dart';
import '../models/search_result.dart';

/// 手册数据仓库：所有数据均通过后端 API 获取。
///
/// 接口对应关系：
/// - [getCategories]  -> GET /api/categories
/// - [getManuals]      -> GET /api/manuals?category_id=
/// - [getChapters]     -> GET /api/manuals/{manual_id}/chapters
/// - [getChapterImages]-> GET /api/manuals/{manual_id}/chapters/{chapter_id}/images
/// - [search]          -> GET /api/search?q=
class ManualsRepository {
  ManualsRepository(this._dio);

  final Dio _dio;

  /// 统一的 GET 封装：解析 JSON 并把底层异常映射为 [ApiException]。
  Future<T> _get<T>(
    String path, {
    Map<String, Object?>? query,
    required T Function(Object? data) parse,
  }) async {
    try {
      final response = await _dio.get<Object?>(path, queryParameters: query);
      return parse(response.data);
    } on Object catch (error) {
      throw mapNetworkError(error);
    }
  }

  /// 分类列表（可按 categoryId 过滤，不传则取全部）。
  Future<List<Category>> getCategories({int? categoryId}) {
    return _get<List<Category>>(
      '/api/categories',
      query: categoryId == null ? null : {'category_id': categoryId},
      parse: (data) => (data as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Category.fromJson)
          .toList(),
    );
  }

  /// 某分类（categoryId）下的手册列表。
  Future<List<Manual>> getManuals(int categoryId) {
    return _get<List<Manual>>(
      '/api/manuals',
      query: {'category_id': categoryId},
      parse: (data) => (data as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Manual.fromJson)
          .toList(),
    );
  }

  /// 某本手册的章节列表（按 chapter_no 排序）。
  Future<List<Chapter>> getChapters(int manualId) {
    return _get<List<Chapter>>(
      '/api/manuals/$manualId/chapters',
      parse: (data) => (data as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Chapter.fromJson)
          .toList(),
    );
  }

  /// 某章节的图片列表（按 sort_order 排序）。
  Future<ChapterImages> getChapterImages(int manualId, int chapterId) {
    return _get<ChapterImages>(
      '/api/manuals/$manualId/chapters/$chapterId/images',
      parse: (data) =>
          ChapterImages.fromJson((data as Map).cast<String, Object?>()),
    );
  }

  /// 全局搜索：品牌 / 手册名称 / 章节标题。
  Future<SearchResult> search(String keyword) {
    return _get<SearchResult>(
      '/api/search',
      query: {'q': keyword},
      parse: (data) =>
          SearchResult.fromJson((data as Map).cast<String, Object?>()),
    );
  }
}
