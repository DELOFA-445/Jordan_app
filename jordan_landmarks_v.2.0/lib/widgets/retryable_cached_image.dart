import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_utils.dart';
import '../utils/app_localizations.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../pages/image_viewer_page.dart';

class RetryableCachedImage extends StatefulWidget {
  String imageUrl;
  double? height;
  double? width;
  bool isZoomable;
  String? heroTag;

  RetryableCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.isZoomable = false,
    this.heroTag,
  });

  @override
  State<RetryableCachedImage> createState() {
    return _RetryableCachedImageState();
  }
}

class _RetryableCachedImageState extends State<RetryableCachedImage> {
  Key retryKey = UniqueKey();

  retry() async {
    await landmarkImageCacheManager.removeFile(widget.imageUrl);
    if (mounted == true) {
      setState(() {
        retryKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = 220.0;
    if (widget.height != null) {
      h = widget.height!;
    }

    var w = double.infinity;
    if (widget.width != null) {
      w = widget.width!;
    }

    var english = settingsViewModel.isEnglish;

    Widget img = CachedNetworkImage(
      key: retryKey,
      imageUrl: widget.imageUrl,
      height: h,
      width: w,
      fit: BoxFit.cover,
      cacheManager: landmarkImageCacheManager,
      fadeInDuration: Duration(milliseconds: 0),
      fadeOutDuration: Duration(milliseconds: 0),
      useOldImageOnUrlChange: true,
      placeholder: (context, url) {
        return SizedBox(
          height: h,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, err) {
        return SizedBox(
          height: h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 28, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.get('image_error', english),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: () {
                    retry();
                  },
                  icon: Icon(Icons.refresh, size: 14),
                  label: Text(
                    AppLocalizations.get('retry', english),
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.isZoomable == true) {
      var tag = widget.imageUrl;
      if (widget.heroTag != null) {
        tag = widget.heroTag!;
      }

      img = Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, anim, anim2) {
                    return FadeTransition(
                      opacity: anim,
                      child: ImageViewerPage(
                        imageUrl: widget.imageUrl,
                        heroTag: tag,
                      ),
                    );
                  },
                  transitionDuration: Duration(milliseconds: 300),
                ),
              );
            },
            child: img,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: img,
      ),
    );
  }
}
