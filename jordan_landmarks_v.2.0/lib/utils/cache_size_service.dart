import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'app_localizations.dart';

class CacheSizeService {
  static int cacheLimitBytes = 100 * 1024 * 1024;
  static String cacheKey = 'landmarkImages';

  static getCacheDirectorySize() async {
    if (kIsWeb == true) {
      return 0;
    }

    try {
      var tempDir = await getTemporaryDirectory();
      var cacheDir = Directory('${tempDir.path}/${cacheKey}');

      if (cacheDir.existsSync() == false) {
        return 0;
      }

      var totalSize = 0;
      var fileList = cacheDir.listSync(recursive: true, followLinks: false);
      
      for (var i = 0; i < fileList.length; i++) {
        var entity = fileList[i];
        if (entity is File) {
          var length = await entity.length();
          totalSize = totalSize + length;
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating cache size: ' + e.toString());
      return 0;
    }
  }

  static checkAndPromptCacheLimit(BuildContext context) async {
    var sizeInBytes = await getCacheDirectorySize();
    var english = settingsViewModel.isEnglish;

    if (sizeInBytes >= cacheLimitBytes) {
      if (context.mounted == true) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.storage, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.get('cache_limit_title', english),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Text(
                AppLocalizations.get('cache_limit_desc', english),
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    AppLocalizations.get('acknowledge', english),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
