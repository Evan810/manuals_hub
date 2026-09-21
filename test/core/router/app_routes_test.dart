import 'package:flutter_test/flutter_test.dart';
import 'package:manuals_hub/core/router/app_routes.dart';

void main() {
  group('AppRoutes 深链 URL 构造', () {
    test('chaptersPath 默认不带 query，标题被编码进 query', () {
      expect(AppRoutes.chaptersPath('12'), '/CategoryList/12');

      final uri = Uri.parse(AppRoutes.chaptersPath('12', title: '三菱 2.0 手册'));
      expect(uri.path, '/CategoryList/12');
      expect(uri.queryParameters['title'], '三菱 2.0 手册');
    });

    test('categoryListPath 携带 id 与可选标题', () {
      final uri = Uri.parse(AppRoutes.categoryListPath(3, title: '其他'));
      expect(uri.path, '/CategoryList');
      expect(uri.queryParameters['id'], '3');
      expect(uri.queryParameters['title'], '其他');

      final minimal = Uri.parse(AppRoutes.categoryListPath(0));
      expect(minimal.queryParameters['id'], '0');
      expect(minimal.queryParameters.containsKey('title'), isFalse);
    });

    test('localManualPath 仅 id 必填，entry/anchor/title 按需出现', () {
      final base = Uri.parse(AppRoutes.localManualPath(7));
      expect(base.path, '/manual/7');
      expect(base.queryParameters.isEmpty, isTrue);

      final full = Uri.parse(
        AppRoutes.localManualPath(
          7,
          entryRelative: 'html/001/chapter.html',
          anchor: 'p12',
          title: '第一章 操作',
        ),
      );
      expect(full.path, '/manual/7');
      expect(full.queryParameters['entry'], 'html/001/chapter.html');
      expect(full.queryParameters['anchor'], 'p12');
      expect(full.queryParameters['title'], '第一章 操作');
    });

    test('非法 id 经 int.tryParse 得到 null（路由层据此显示兜底页）', () {
      expect(int.tryParse('/manual/abc'.split('/').last), isNull);
    });
  });
}
