import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jordan_landmarks/utils/app_utils.dart';
import 'package:jordan_landmarks/utils/http_overrides_io.dart';

void main() {
  test('fetch archive.org image', () async {
    HttpOverrides.global = ArchiveHttpOverrides();

    final cacheManager = CacheManager(
      Config(
        'testCache2',
        stalePeriod: const Duration(days: 7),
      ),
    );

    final url = 'https://ia600707.us.archive.org/10/items/jarash_1/wadi_rum_1.webp';
    try {
      final fileInfo = await cacheManager.downloadFile(url);
      expect(fileInfo.file.existsSync(), isTrue);
      print('SUCCESS: File downloaded to: \${fileInfo.file.path}');
    } catch (e, stack) {
      print('CAUGHT ERROR: \$e');
      print('STACKTRACE: \$stack');
    }
  });
}
