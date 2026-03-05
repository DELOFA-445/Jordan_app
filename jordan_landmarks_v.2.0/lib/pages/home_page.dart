import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';
import '../utils/cache_size_service.dart';
import '../widgets/retryable_cached_image.dart';
import 'settings_page.dart';
import 'fullscreen_video_page.dart';
import 'aqaba_detail_page.dart';
import 'wadirum_detail_page.dart';
import 'jerash_detail_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeViewModel vm = HomeViewModel();

  @override
  void initState() {
    super.initState();
    vm.addListener(update);
    settingsViewModel.addListener(update);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CacheSizeService.checkAndPromptCacheLimit(context);
    });
  }

  void update() {
    setState(() {});
  }

  @override
  void dispose() {
    vm.removeListener(update);
    settingsViewModel.removeListener(update);
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
        title: Text(
          AppLocalizations.get('app_title', english),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: vm.hasVideoError
                      ? SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  AppLocalizations.get('video_error', english),
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    vm.retryVideo();
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text(
                                    AppLocalizations.get('retry', english),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : vm.isInitialized
                      ? Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                vm.togglePlayPause();
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: vm.controller.value.aspectRatio,
                                    child: VideoPlayer(vm.controller),
                                  ),
                                  if (!vm.controller.value.isPlaying)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            VideoProgressIndicator(
                              vm.controller,
                              allowScrubbing: true,
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      vm.isMuted || vm.controller.value.volume == 0
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      size: 22,
                                      color: Colors.brown.shade700,
                                    ),
                                    onPressed: () {
                                      vm.toggleMute();
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  vm.isDownloading
                                      ? Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              value: vm.downloadProgress > 0
                                                  ? vm.downloadProgress
                                                  : null,
                                              strokeWidth: 2.5,
                                              color: Colors.brown.shade700,
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            vm.isVideoDownloaded
                                                ? Icons.download_done
                                                : Icons.download,
                                            size: 22,
                                            color: vm.isVideoDownloaded
                                                ? Colors.green.shade700
                                                : Colors.brown.shade700,
                                          ),
                                          onPressed: vm.isVideoDownloaded
                                              ? null
                                              : () {
                                                  vm.downloadVideo();
                                                },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.fullscreen,
                                      size: 22,
                                      color: Colors.brown.shade700,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenVideoPage(
                                                viewModel: vm,
                                              ),
                                        ),
                                      );
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.get('home_welcome', english),
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85, initialPage: 4998),
                  itemCount: 9999,
                  itemBuilder: (context, index) {
                    var i = index % 3;

                    String titleKey;
                    String imageUrl;
                    Widget page;

                    if (i == 0) {
                      titleKey = 'aqaba_title';
                      imageUrl = 'https://ia600707.us.archive.org/10/items/jarash_1/aqaba_1.webp';
                      page = AqabaDetailPage();
                    } else if (i == 1) {
                      titleKey = 'wadirum_title';
                      imageUrl = 'https://ia600707.us.archive.org/10/items/jarash_1/wadi_rum_1.webp';
                      page = WadiRumDetailPage();
                    } else {
                      titleKey = 'jerash_title';
                      imageUrl = 'https://ia600707.us.archive.org/10/items/jarash_1/jarash_1.webp';
                      page = JerashDetailPage();
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => page),
                          );
                        },
                        child: SizedBox(
                          width: 160,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                RetryableCachedImage(
                                  imageUrl: imageUrl,
                                  height: 200,
                                  width: 160,
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                  child: Text(
                                    AppLocalizations.get(titleKey, english),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(blurRadius: 4, color: Colors.black54),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
