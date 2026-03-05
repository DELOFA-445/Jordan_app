import 'package:flutter/material.dart';
import '../viewmodels/favourites_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';
import '../widgets/retryable_cached_image.dart';
import 'settings_page.dart';
import 'petra_detail_page.dart';
import 'deadsea_detail_page.dart';
import 'wadirum_detail_page.dart';
import 'jerash_detail_page.dart';
import 'aqaba_detail_page.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  @override
  void initState() {
    super.initState();
    favouritesViewModel.addListener(_onChanged);
    settingsViewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    favouritesViewModel.removeListener(_onChanged);
    settingsViewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;
    var favs = favouritesViewModel.getFavouritesList();

    // build list of fav cards
    List<Widget> favCards = [];

    if (favs.contains('petra_title')) {
      favCards.add(_buildCard(
        AppLocalizations.get('petra_title', english),
        AppLocalizations.get('petra_info', english),
        'https://ia600707.us.archive.org/10/items/jarash_1/petra_1.webp',
        PetraDetailPage(),
        'petra_title',
        english,
      ));
    }

    if (favs.contains('deadsea_title')) {
      favCards.add(_buildCard(
        AppLocalizations.get('deadsea_title', english),
        AppLocalizations.get('deadsea_info', english),
        'https://ia800707.us.archive.org/10/items/jarash_1/Dead_Sea_1.webp',
        DeadSeaDetailPage(),
        'deadsea_title',
        english,
      ));
    }

    if (favs.contains('wadirum_title')) {
      favCards.add(_buildCard(
        AppLocalizations.get('wadirum_title', english),
        AppLocalizations.get('wadirum_info', english),
        'https://ia600707.us.archive.org/10/items/jarash_1/wadi_rum_1.webp',
        WadiRumDetailPage(),
        'wadirum_title',
        english,
      ));
    }

    if (favs.contains('jerash_title')) {
      favCards.add(_buildCard(
        AppLocalizations.get('jerash_title', english),
        AppLocalizations.get('jerash_info', english),
        'https://ia600707.us.archive.org/10/items/jarash_1/jarash_1.webp',
        JerashDetailPage(),
        'jerash_title',
        english,
      ));
    }

    if (favs.contains('aqaba_title')) {
      favCards.add(_buildCard(
        AppLocalizations.get('aqaba_title', english),
        AppLocalizations.get('aqaba_info', english),
        'https://ia600707.us.archive.org/10/items/jarash_1/aqaba_1.webp',
        AqabaDetailPage(),
        'aqaba_title',
        english,
      ));
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
          AppLocalizations.get('nav_favourites', english),
        ),
      ),
      body: SafeArea(
        child: favCards.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.brown.shade300,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.get('no_favourites', english),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade400,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.all(12),
                cacheExtent: 2000,
                children: favCards,
              ),
      ),
    );
  }

  Widget _buildCard(String title, String info, String imageUrl, Widget page, String titleKey, bool english) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 110,
                child: RetryableCachedImage(
                  imageUrl: imageUrl,
                  height: 110,
                  width: 110,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => page,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.get('explore', english),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () {
                                favouritesViewModel.removeFavourite(titleKey);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
