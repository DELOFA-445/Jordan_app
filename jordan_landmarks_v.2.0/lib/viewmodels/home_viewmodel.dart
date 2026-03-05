import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:typed_data';
import 'settings_viewmodel.dart';
import '../utils/app_utils.dart';

class HomeViewModel extends ChangeNotifier {
  late VideoPlayerController controller;
  bool isMuted = false;
  bool hasVideoError = false;
  bool isInitialized = false;
  var currentQuality;

  bool isDownloading = false;
  double downloadProgress = 0.0;
  bool isVideoDownloaded = false;

  HomeViewModel() {
    currentQuality = settingsViewModel.videoQuality;
    initializeVideo();
    settingsViewModel.addListener(updateSettings);
  }

  void updateSettings() {
    if (settingsViewModel.videoQuality != currentQuality) {
      currentQuality = settingsViewModel.videoQuality;
      controller.dispose();
      initializeVideo();
    }
  }

  String getVideoUrl(String quality) {
    return 'https://ia902805.us.archive.org/17/items/intro_video_360p/intro_video_' + quality + '.mp4';
  }

  resolveQuality() async {
    var setting = settingsViewModel.videoQuality;
    if (setting == VideoQuality.high) {
      return '480p';
    }
    if (setting == VideoQuality.low) {
      return '360p';
    }

    try {
      var stopwatch = Stopwatch();
      stopwatch.start();
      var client = HttpClient();
      var request = await client.getUrl(Uri.parse(getVideoUrl('360p')));
      request.headers.set('Range', 'bytes=0-51200');
      var response = await request.close();
      var bytes = 0;
      
      await for (var chunk in response) {
        bytes = bytes + chunk.length;
      }
      
      stopwatch.stop();
      client.close();

      var seconds = stopwatch.elapsedMilliseconds / 1000.0;
      var kbps = (bytes / 1024) / seconds;
      if (kbps >= 100) {
        return '480p';
      } else {
        return '360p';
      }
    } catch (e) {
      return '360p';
    }
  }

  findAnyCachedVideo() async {
    var qualities = ['480p', '360p'];
    for (var i = 0; i < qualities.length; i++) {
      var q = qualities[i];
      var info = await videoCacheManager.getFileFromCache(getVideoUrl(q));
      if (info != null) {
        return info.file;
      }
    }
    return null;
  }

  void initializeVideo() async {
    hasVideoError = false;
    isInitialized = false;
    notifyListeners();

    String? quality;
    File? cachedFile;

    try {
      quality = await resolveQuality();
      var url = getVideoUrl(quality!);

      var fileInfo = await videoCacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        cachedFile = fileInfo.file;
        isVideoDownloaded = true;
      }
    } catch (e) {
      cachedFile = await findAnyCachedVideo();
      if (cachedFile != null) {
        isVideoDownloaded = true;
      } else {
        isVideoDownloaded = false;
      }
    }

    if (cachedFile != null) {
      controller = VideoPlayerController.file(cachedFile);
    } else if (quality != null) {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(getVideoUrl(quality)),
      );
    } else {
      hasVideoError = true;
      notifyListeners();
      return;
    }

    try {
      await controller.initialize();
      isInitialized = true;
      notifyListeners();
    } catch (error) {
      var fallback = await findAnyCachedVideo();
      if (fallback != null) {
        isVideoDownloaded = true;
        controller = VideoPlayerController.file(fallback);
        try {
          await controller.initialize();
          isInitialized = true;
          notifyListeners();
        } catch (e) {
          hasVideoError = true;
          notifyListeners();
        }
        controller.addListener(() {
          notifyListeners();
        });
      } else {
        hasVideoError = true;
        notifyListeners();
      }
    }

    controller.addListener(() {
      notifyListeners();
    });

    notifyListeners();
  }

  downloadVideo() async {
    if (isDownloading == true) {
      return;
    }

    isDownloading = true;
    downloadProgress = 0.0;
    notifyListeners();

    try {
      var quality = await resolveQuality();
      var url = getVideoUrl(quality);

      var client = HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();

      var totalBytes = response.contentLength;
      var receivedBytes = 0;
      List<List<int>> chunks = [];

      await for (var chunk in response) {
        chunks.add(chunk);
        receivedBytes = receivedBytes + chunk.length;
        if (totalBytes > 0) {
          downloadProgress = receivedBytes / totalBytes;
          notifyListeners();
        }
      }
      client.close();

      var allBytes = BytesBuilder();
      for (var i = 0; i < chunks.length; i++) {
        allBytes.add(chunks[i]);
      }

      await videoCacheManager.putFile(
        url,
        allBytes.toBytes(),
        fileExtension: 'mp4',
      );

      isVideoDownloaded = true;
      isDownloading = false;
      downloadProgress = 1.0;
      notifyListeners();
    } catch (e) {
      isDownloading = false;
      downloadProgress = 0.0;
      notifyListeners();
    }
  }

  void retryVideo() {
    controller.dispose();
    initializeVideo();
  }

  seekRelative(Duration duration) async {
    var currentPosition = await controller.position;
    if (currentPosition != null) {
      var newPosition = currentPosition + duration;
      await controller.seekTo(newPosition);
    }
  }

  void setVolume(double volume) {
    controller.setVolume(volume);
    if (volume == 0) {
      isMuted = true;
    } else {
      isMuted = false;
    }
    notifyListeners();
  }

  void toggleMute() {
    if (isMuted == true) {
      isMuted = false;
    } else {
      isMuted = true;
    }
    
    if (isMuted == true) {
      controller.setVolume(0.0);
    } else {
      controller.setVolume(1.0);
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (controller.value.isPlaying == true) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  void dispose() {
    settingsViewModel.removeListener(updateSettings);
    controller.removeListener(() {});
    controller.dispose();
    super.dispose();
  }
}
