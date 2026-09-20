import 'package:manuals_hub/core/network/dio_client.dart';

/// 手册中的一个章节。
///
/// 对应接口：`GET /api/manuals/{manual_id}/chapters`
class Chapter {
  const Chapter({
    required this.id,
    required this.chapterNo,
    required this.title,
    required this.isReader,
    this.htmlPath,
    this.pageStart,
    this.pageEnd,
    this.entryUrl,
  });

  /// 章节 id（接口字段 chapter_id）。
  final int id;

  /// 章节序号。
  final int chapterNo;

  final String title;

  /// 章节对应的 HTML 相对路径。
  final String? htmlPath;

  /// 阅读器模式的起止页码。
  final int? pageStart;
  final int? pageEnd;

  /// 是否走 reader.html 分页阅读。
  final bool isReader;

  /// 章节入口完整地址。
  final String? entryUrl;

  factory Chapter.fromJson(Map<String, Object?> json) {
    final entryUrl = json['entry_url'] as String?;
    return Chapter(
      id: json['chapter_id'] as int,
      chapterNo: json['chapter_no'] as int,
      title: json['title'] as String,
      htmlPath: json['html_path'] as String?,
      pageStart: json['page_start'] as int?,
      pageEnd: json['page_end'] as int?,
      isReader: json['is_reader'] as bool? ?? false,
      entryUrl: entryUrl == null ? null : DioClient.resolveUrl(entryUrl),
    );
  }
}
