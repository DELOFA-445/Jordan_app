import 'package:flutter/material.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';
import 'rate_app_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    settingsViewModel.addListener(update);
  }

  @override
  void dispose() {
    settingsViewModel.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  String getContrastText(ContrastLevel level) {
    var english = settingsViewModel.isEnglish;
    if (level == ContrastLevel.low) {
      return AppLocalizations.get('contrast_low', english);
    } else if (level == ContrastLevel.medium) {
      return AppLocalizations.get('contrast_medium', english);
    } else {
      return AppLocalizations.get('contrast_high', english);
    }
  }

  String getTextSizeText(double factor) {
    var percentage = factor * 100;
    var rounded = percentage.round();
    return rounded.toString() + '%';
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    List<Widget> contrastRadios = [];
    var levels = [ContrastLevel.low, ContrastLevel.medium, ContrastLevel.high];
    
    for (var i = 0; i < levels.length; i++) {
      contrastRadios.add(
        RadioListTile<ContrastLevel>(
          title: Text(getContrastText(levels[i])),
          value: levels[i],
          groupValue: settingsViewModel.contrast,
          onChanged: (value) {
            if (value != null) {
              settingsViewModel.setContrast(value);
            }
          },
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.get('settings_title', english),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contrast),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.get('contrast', english),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Column(
                      children: contrastRadios,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.get('text_size', english),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('أ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: settingsViewModel.textScaleFactor,
                            min: 1.0,
                            max: 2.0,
                            divisions: 4,
                            label: getTextSizeText(settingsViewModel.textScaleFactor),
                            onChanged: (value) {
                              settingsViewModel.setTextScaleFactor(value);
                            },
                          ),
                        ),
                        Text('أ', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                    Center(
                      child: Text(
                        getTextSizeText(settingsViewModel.textScaleFactor),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                secondary: Icon(
                  settingsViewModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                title: Text(
                  AppLocalizations.get('dark_mode', english),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  settingsViewModel.isDarkMode
                      ? AppLocalizations.get('enabled', english)
                      : AppLocalizations.get('disabled', english),
                ),
                value: settingsViewModel.isDarkMode,
                onChanged: (value) {
                  settingsViewModel.setDarkMode(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                secondary: Icon(
                  settingsViewModel.soundEnabled ? Icons.volume_up : Icons.volume_off,
                ),
                title: Text(
                  AppLocalizations.get('sound', english),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  settingsViewModel.soundEnabled
                      ? AppLocalizations.get('enabled', english)
                      : AppLocalizations.get('disabled', english),
                ),
                value: settingsViewModel.soundEnabled,
                onChanged: (value) {
                  settingsViewModel.setSoundEnabled(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.high_quality),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.get('video_quality', english),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    RadioListTile<VideoQuality>(
                      title: Text(AppLocalizations.get('quality_auto', english)),
                      value: VideoQuality.auto,
                      groupValue: settingsViewModel.videoQuality,
                      onChanged: (value) {
                        if (value != null) {
                          settingsViewModel.setVideoQuality(value);
                        }
                      },
                    ),
                    RadioListTile<VideoQuality>(
                      title: Text(AppLocalizations.get('quality_low', english)),
                      value: VideoQuality.low,
                      groupValue: settingsViewModel.videoQuality,
                      onChanged: (value) {
                        if (value != null) {
                          settingsViewModel.setVideoQuality(value);
                        }
                      },
                    ),
                    RadioListTile<VideoQuality>(
                      title: Text(AppLocalizations.get('quality_high', english)),
                      value: VideoQuality.high,
                      groupValue: settingsViewModel.videoQuality,
                      onChanged: (value) {
                        if (value != null) {
                          settingsViewModel.setVideoQuality(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                secondary: Icon(Icons.language),
                title: Text(
                  AppLocalizations.get('language', english),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  settingsViewModel.isEnglish
                      ? AppLocalizations.get('language_english', english)
                      : AppLocalizations.get('language_arabic', english),
                ),
                value: settingsViewModel.isEnglish,
                onChanged: (value) {
                  settingsViewModel.setLanguage(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.star_rate),
                title: Text(
                  AppLocalizations.get('rate_app', english),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.get('share_opinion', english),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RateAppPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
