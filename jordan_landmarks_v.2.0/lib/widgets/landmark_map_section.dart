import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../utils/app_localizations.dart';
import '../viewmodels/settings_viewmodel.dart';

class LandmarkMapSection extends StatefulWidget {
  double latitude;
  double longitude;
  String landmarkName;

  LandmarkMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.landmarkName,
  });

  @override
  State<LandmarkMapSection> createState() {
    return _LandmarkMapSectionState();
  }
}

class _LandmarkMapSectionState extends State<LandmarkMapSection> with WidgetsBindingObserver {
  double? distanceInKm;
  String? errorMessage;
  bool isWaitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    determinePositionAndCalculateDistance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isWaitingForSettings == true) {
        isWaitingForSettings = false;
        if (distanceInKm == null) {
          determinePositionAndCalculateDistance();
        }
      }
    }
  }

  hasInternet() async {
    try {
      var result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty == true && result[0].rawAddress.isNotEmpty == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  determinePositionAndCalculateDistance() async {
    if (mounted == false) {
      return;
    }
    
    var english = settingsViewModel.isEnglish;

    var internet = await hasInternet();
    if (internet == false) {
      if (mounted == true) {
        setState(() {
          errorMessage = AppLocalizations.get('no_internet', english);
        });
      }
      return;
    }

    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      if (mounted == true) {
        setState(() {
          errorMessage = AppLocalizations.get('location_disabled', english);
        });
      }
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (mounted == true) {
        setState(() {
          errorMessage = AppLocalizations.get('location_denied', english);
        });
      }
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted == true) {
        setState(() {
          errorMessage = AppLocalizations.get('location_denied_forever', english);
        });
      }
      return;
    }

    try {
      var position = await Geolocator.getCurrentPosition();
      var distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.latitude,
        widget.longitude,
      );
      
      if (mounted == true) {
        setState(() {
          errorMessage = null; 
          distanceInKm = distanceInMeters / 1000;
        });
      }
    } catch (e) {
      if (mounted == true) {
         setState(() {
           errorMessage = AppLocalizations.get('location_denied', english);
         });
      }
    }
  }

  openGoogleMaps() async {
    var lat = widget.latitude.toString();
    var lng = widget.longitude.toString();
    var urlString = 'https://www.google.com/maps/search/?api=1&query=' + lat + ',' + lng;
    var url = Uri.parse(urlString);
    
    var canLaunch = await canLaunchUrl(url);
    if (canLaunch == true) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;
    var targetLocation = LatLng(widget.latitude, widget.longitude);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.map, color: Colors.brown.shade800),
                SizedBox(width: 12),
                Text(
                  AppLocalizations.get('map_section_title', english),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ),
          ),
          
          if (errorMessage != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (errorMessage == AppLocalizations.get('no_internet', english)) {
                        determinePositionAndCalculateDistance();
                        return;
                      }

                      if (errorMessage == AppLocalizations.get('location_disabled', english)) {
                        isWaitingForSettings = true;
                        await Geolocator.openLocationSettings();
                        return;
                      }

                      setState(() { 
                        errorMessage = null; 
                      });
                      
                      try {
                        var perm = await Geolocator.checkPermission();
                        if (perm == LocationPermission.denied) {
                           perm = await Geolocator.requestPermission();
                        }
                        
                        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
                          await determinePositionAndCalculateDistance();
                        } else if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
                           isWaitingForSettings = true;
                           await Geolocator.openAppSettings();
                        }
                      } catch (e) {
                         setState(() {
                             errorMessage = AppLocalizations.get('location_denied', english);
                         });
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      errorMessage == AppLocalizations.get('no_internet', english)
                          ? (english ? 'RETRY' : 'إعادة المحاولة')
                          : errorMessage == AppLocalizations.get('location_disabled', english)
                              ? (english ? 'ENABLE' : 'تفعيل')
                              : (english ? 'GRANT' : 'سماح'),
                    ),
                  ),
                ],
              ),
            )
          else if (distanceInKm != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.brown.shade100,
              child: Text(
                distanceInKm!.toStringAsFixed(1) + ' ' + AppLocalizations.get('distance_away', english),
                style: TextStyle(
                  color: Colors.brown.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            )
          else 
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(),
            ),

          SizedBox(
            height: 250,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: targetLocation,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.jordan_landmarks',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: targetLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.landmarkName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                openGoogleMaps();
              },
              icon: Icon(Icons.open_in_new, size: 20),
              label: Text(
                AppLocalizations.get('open_google_maps', english),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
