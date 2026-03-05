import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../viewmodels/home_viewmodel.dart';

class FullScreenVideoPage extends StatefulWidget {
  HomeViewModel viewModel;

  FullScreenVideoPage({super.key, required this.viewModel});

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.viewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onUpdate);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var ctrl = widget.viewModel.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: ctrl.value.aspectRatio,
                child: VideoPlayer(ctrl),
              ),
            ),

            if (showControls)
              Container(
                color: Colors.black38,
                child: SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              widget.viewModel.seekRelative(Duration(seconds: -10));
                            },
                          ),
                          SizedBox(width: 24),
                          IconButton(
                            icon: Icon(
                              ctrl.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                              size: 60,
                            ),
                            onPressed: () {
                              widget.viewModel.togglePlayPause();
                            },
                          ),
                          SizedBox(width: 24),
                          IconButton(
                            icon: Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              widget.viewModel.seekRelative(Duration(seconds: 10));
                            },
                          ),
                        ],
                      ),

                      Spacer(),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            VideoProgressIndicator(
                              ctrl,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.white,
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.white10,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    widget.viewModel.isMuted || ctrl.value.volume == 0
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    widget.viewModel.toggleMute();
                                  },
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.white,
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                    ),
                                    child: Slider(
                                      value: widget.viewModel.isMuted
                                          ? 0.0
                                          : ctrl.value.volume,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (val) {
                                        widget.viewModel.setVolume(val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
