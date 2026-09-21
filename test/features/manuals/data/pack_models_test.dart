import 'package:flutter_test/flutter_test.dart';
import 'package:manuals_hub/features/manuals/data/packs/pack_models.dart';

void main() {
  group('PackManifest / PackInfo', () {
    test('从服务端 manifest 结构解析并可按 manualId 查找', () {
      final manifest = PackManifest.fromJson({
        'generated': '2026-05-21T00:00:00',
        'packs': [
          {
            'manual_id': 36,
            'title': 'elevator util',
            'category_id': 3,
            'category': '其他',
            'path': 'elevator_util',
            'entry': 'index.html',
            'icon': 'icon.png',
            'file_count': 966,
            'size_bytes': 390000000,
            'packed_size': 345000000,
            'sha256': 'abc123',
            'url': '/packs/3/elevator_util.zip',
          },
          {'manual_id': 2, 'title': 'minimal', 'category_id': 0},
        ],
      });

      expect(manifest.packs, hasLength(2));
      final info = manifest.forManual(36)!;
      expect(info.path, 'elevator_util');
      expect(info.sha256, 'abc123');
      expect(info.packedSize, 345000000);
      expect(manifest.forManual(999), isNull);

      // 缺省字段兜底。
      final minimal = manifest.forManual(2)!;
      expect(minimal.entry, 'index.html');
      expect(minimal.fileCount, 0);
      expect(minimal.url, '');
    });

    test('PackEntryState.copyWith 保留未覆盖字段', () {
      const state = PackEntryState(
        status: PackStatus.ready,
        progress: 1,
        hasUpdate: true,
      );
      final next = state.copyWith(hasUpdate: false);
      expect(next.status, PackStatus.ready);
      expect(next.progress, 1);
      expect(next.hasUpdate, isFalse);
    });
  });
}
