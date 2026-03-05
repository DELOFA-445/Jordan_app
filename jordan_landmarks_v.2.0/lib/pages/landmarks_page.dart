import 'package:flutter/material.dart';
import '../widgets/retryable_cached_image.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/favourites_viewmodel.dart';
import '../utils/app_localizations.dart';
import 'settings_page.dart';
import 'petra_detail_page.dart';
import 'deadsea_detail_page.dart';
import 'wadirum_detail_page.dart';
import 'jerash_detail_page.dart';
import 'aqaba_detail_page.dart';

class LandmarksPage extends StatefulWidget {
  LandmarksPage({super.key});

  @override
  State<LandmarksPage> createState() => _LandmarksPageState();
}

class _LandmarksPageState extends State<LandmarksPage> {
  String searchText = '';
  List<IconData> selectedTags = [];

  @override
  void initState() {
    super.initState();
    settingsViewModel.addListener(update);
    favouritesViewModel.addListener(update);
  }

  @override
  void dispose() {
    settingsViewModel.removeListener(update);
    favouritesViewModel.removeListener(update);
    super.dispose();
  }

  void update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    var allTitles = ['petra_title', 'deadsea_title', 'wadirum_title', 'jerash_title', 'aqaba_title'];
    var allInfos = ['petra_info', 'deadsea_info', 'wadirum_info', 'jerash_info', 'aqaba_info'];
    var allImages = [
      'https://ia600707.us.archive.org/10/items/jarash_1/petra_1.webp',
      'https://ia800707.us.archive.org/10/items/jarash_1/Dead_Sea_1.webp',
      'https://ia600707.us.archive.org/10/items/jarash_1/wadi_rum_1.webp',
      'https://ia600707.us.archive.org/10/items/jarash_1/jarash_1.webp',
      'https://ia600707.us.archive.org/10/items/jarash_1/aqaba_1.webp',
    ];
    var allIcons = [
      [Icons.family_restroom, Icons.wb_sunny, Icons.directions_car],
      [Icons.family_restroom, Icons.wb_sunny, Icons.directions_car],
      [Icons.directions_run, Icons.cabin, Icons.directions_car],
      [Icons.account_balance, Icons.family_restroom, Icons.directions_car],
      [Icons.beach_access, Icons.scuba_diving, Icons.directions_car],
    ];
    var allPages = [
      PetraDetailPage(),
      DeadSeaDetailPage(),
      WadiRumDetailPage(),
      JerashDetailPage(),
      AqabaDetailPage(),
    ];

    List<IconData> allTagIcons = [];
    for (var i = 0; i < allIcons.length; i++) {
      for (var ic in allIcons[i]) {
        if (!allTagIcons.contains(ic)) {
          allTagIcons.add(ic);
        }
      }
    }

    List<int> filtered = [];
    for (var i = 0; i < allTitles.length; i++) {
      var title = AppLocalizations.get(allTitles[i], english).toLowerCase();
      var info = AppLocalizations.get(allInfos[i], english).toLowerCase();

      var matchSearch = title.contains(searchText) || info.contains(searchText);

      var matchTags = true;
      for (var tag in selectedTags) {
        if (!allIcons[i].contains(tag)) {
          matchTags = false;
          break;
        }
      }

      if (matchSearch && matchTags) {
        filtered.add(i);
      }
    }

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
          AppLocalizations.get('landmarks_title', english),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('search', english),
                  prefixIcon: Icon(Icons.search, color: Colors.brown),
                  filled: true,
                  fillColor: Colors.brown.shade50,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: allTagIcons.length,
                itemBuilder: (context, index) {
                  var icon = allTagIcons[index];
                  var isSelected = selectedTags.contains(icon);
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: isSelected ? null : Icon(icon, size: 18, color: Colors.brown.shade700),
                      label: isSelected
                        ? Icon(icon, size: 18, color: Colors.white)
                        : SizedBox.shrink(),
                      labelPadding: EdgeInsets.zero,
                      padding: EdgeInsets.all(8),
                      backgroundColor: Colors.brown.shade100,
                      selectedColor: Colors.brown.shade600,
                      shape: CircleBorder(),
                      side: BorderSide.none,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(icon);
                          } else {
                            selectedTags.remove(icon);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                cacheExtent: 2000,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  var i = filtered[index];
                  var title = AppLocalizations.get(allTitles[i], english);
                  var info = AppLocalizations.get(allInfos[i], english);
                  var loveIt = favouritesViewModel.isFavourite(allTitles[i]);

                  List<Widget> iconWidgets = [];
                  for (var ic in allIcons[i]) {
                    iconWidgets.add(
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(ic, size: 16, color: Colors.white),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: RetryableCachedImage(
                                    imageUrl: allImages[i],
                                    height: 130,
                                    width: 120,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          info,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 4, 10, 6),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: iconWidgets,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    loveIt ? Icons.favorite : Icons.favorite_border,
                                    color: loveIt ? Colors.red : Colors.brown.shade400,
                                  ),
                                  onPressed: () {
                                    favouritesViewModel.toggleFavourite(allTitles[i]);
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => allPages[i]),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown.shade600,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.get('explore', english),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
