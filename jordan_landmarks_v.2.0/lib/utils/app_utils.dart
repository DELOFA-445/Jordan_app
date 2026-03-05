import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../viewmodels/settings_viewmodel.dart';

var landmarkImageCacheManager = CacheManager(
  Config(
    'landmarkImages',
    stalePeriod: Duration(days: 7),
    maxNrOfCacheObjects: 100,
  ),
);

var videoCacheManager = CacheManager(
  Config(
    'landmarkVideos',
    stalePeriod: Duration(days: 7),
    maxNrOfCacheObjects: 5,
  ),
);

void playSound(String assetPath) async {
  if (settingsViewModel.soundEnabled == true) {
    var player = AudioPlayer();
    player.audioCache.prefix = '';
    await player.play(AssetSource(assetPath));
  }
}
