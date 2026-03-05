import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum ContrastLevel { low, medium, high }
enum VideoQuality { auto, low, high }

class SettingsViewModel extends ChangeNotifier {
  ContrastLevel contrast = ContrastLevel.medium;
  double textScaleFactor = 1.0;
  bool isDarkMode = false;
  bool soundEnabled = true;
  bool isEnglish = false;
  VideoQuality videoQuality = VideoQuality.auto;

  Box getBox() {
    return Hive.box('settingsBox');
  }

  void loadFromHive() {
    var box = getBox();
    
    var contrastIndex = box.get('contrast', defaultValue: 1);
    contrast = ContrastLevel.values[contrastIndex];
    
    textScaleFactor = box.get('textScaleFactor', defaultValue: 1.0);
    isDarkMode = box.get('isDarkMode', defaultValue: false);
    soundEnabled = box.get('soundEnabled', defaultValue: true);
    isEnglish = box.get('isEnglish', defaultValue: false);
    
    var qualityIndex = box.get('videoQuality', defaultValue: 0);
    videoQuality = VideoQuality.values[qualityIndex];
    
    notifyListeners();
  }

  void setContrast(ContrastLevel level) {
    contrast = level;
    var box = getBox();
    box.put('contrast', level.index);
    notifyListeners();
  }

  void setTextScaleFactor(double factor) {
    textScaleFactor = factor;
    var box = getBox();
    box.put('textScaleFactor', factor);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    var box = getBox();
    box.put('isDarkMode', value);
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    soundEnabled = value;
    var box = getBox();
    box.put('soundEnabled', value);
    notifyListeners();
  }

  void setLanguage(bool english) {
    isEnglish = english;
    var box = getBox();
    box.put('isEnglish', english);
    notifyListeners();
  }

  void setVideoQuality(VideoQuality quality) {
    videoQuality = quality;
    var box = getBox();
    box.put('videoQuality', quality.index);
    notifyListeners();
  }

  ThemeData getTheme() {
    Color seedColor;
    if (contrast == ContrastLevel.low) {
      seedColor = Colors.brown.shade200;
    } else if (contrast == ContrastLevel.medium) {
      seedColor = Colors.brown;
    } else {
      seedColor = Colors.brown.shade900;
    }

    Brightness currentBrightness;
    if (isDarkMode == true) {
      currentBrightness = Brightness.dark;
    } else {
      currentBrightness = Brightness.light;
    }

    double contrastVal;
    if (contrast == ContrastLevel.high) {
      contrastVal = 1.0;
    } else if (contrast == ContrastLevel.low) {
      contrastVal = -1.0;
    } else {
      contrastVal = 0.0;
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: currentBrightness,
        contrastLevel: contrastVal,
      ),
      useMaterial3: true,
    );
  }
}

var settingsViewModel = SettingsViewModel();
