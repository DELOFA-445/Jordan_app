import 'package:flutter/material.dart';
import '../widgets/retryable_cached_image.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';
import '../widgets/landmark_map_section.dart';
import '../widgets/wikipedia_source_button.dart';
import '../viewmodels/favourites_viewmodel.dart';

class WadiRumDetailPage extends StatelessWidget {
  WadiRumDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              ListenableBuilder(
                listenable: favouritesViewModel,
                builder: (context, _) {
                  var loveIt = favouritesViewModel.isFavourite('wadirum_title');
                  return IconButton(
                    icon: Icon(loveIt ? Icons.favorite : Icons.favorite_border),
                    color: loveIt ? Colors.red : Colors.white,
                    onPressed: () {
                      favouritesViewModel.toggleFavourite('wadirum_title');
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppLocalizations.get('wadirum_title', english),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  RetryableCachedImage(
                    imageUrl: 'https://ia600707.us.archive.org/10/items/jarash_1/wadi_rum_1.webp',
                    height: 260,
                    isZoomable: true,
                    heroTag: 'wadirum_main',
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.brown.shade700,
          ),

          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          avatar: Icon(Icons.directions_run, size: 16, color: Colors.white),
                          label: Text(
                            AppLocalizations.get('wadirum_tag1', english),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Colors.brown.shade400,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                        Chip(
                          avatar: Icon(Icons.cabin, size: 16, color: Colors.white),
                          label: Text(
                            AppLocalizations.get('wadirum_tag2', english),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Colors.brown.shade400,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                        Chip(
                          avatar: Icon(Icons.directions_car, size: 16, color: Colors.white),
                          label: Text(
                            AppLocalizations.get('wadirum_tag3', english),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Colors.brown.shade400,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Text(
                      AppLocalizations.get('wadirum_info', english),
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),

                    SizedBox(height: 24),

                    Card(
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        shape: Border(),
                        collapsedShape: Border(),
                        iconColor: Colors.brown.shade800,
                        collapsedIconColor: Colors.brown.shade800,
                        leading: Icon(Icons.terrain, color: Colors.brown.shade600, size: 24),
                        title: Text(
                          AppLocalizations.get('wadirum_section_geography', english),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              AppLocalizations.get('wadirum_detail_geography', english),
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RetryableCachedImage(
                        imageUrl: 'https://ia600707.us.archive.org/10/items/jarash_1/wadi_rum_2.webp',
                        height: 200,
                        isZoomable: true,
                        heroTag: 'wadirum_second',
                      ),
                    ),

                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        shape: Border(),
                        collapsedShape: Border(),
                        iconColor: Colors.brown.shade800,
                        collapsedIconColor: Colors.brown.shade800,
                        leading: Icon(Icons.explore, color: Colors.brown.shade600, size: 24),
                        title: Text(
                          AppLocalizations.get('wadirum_section_activities', english),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              AppLocalizations.get('wadirum_detail_activities', english),
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        shape: Border(),
                        collapsedShape: Border(),
                        iconColor: Colors.brown.shade800,
                        collapsedIconColor: Colors.brown.shade800,
                        leading: Icon(Icons.movie, color: Colors.brown.shade600, size: 24),
                        title: Text(
                          AppLocalizations.get('wadirum_section_films', english),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              AppLocalizations.get('wadirum_detail_films', english),
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        shape: Border(),
                        collapsedShape: Border(),
                        iconColor: Colors.brown.shade800,
                        collapsedIconColor: Colors.brown.shade800,
                        leading: Icon(Icons.tips_and_updates, color: Colors.brown.shade600, size: 24),
                        title: Text(
                          AppLocalizations.get('wadirum_section_visit', english),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              AppLocalizations.get('wadirum_detail_visit', english),
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    LandmarkMapSection(
                      latitude: 29.531911,
                      longitude: 35.420228,
                      landmarkName: AppLocalizations.get('wadirum_title', english),
                    ),

                    SizedBox(height: 24),

                    WikipediaSourceButton(
                      url: AppLocalizations.get('wadirum_wiki', english),
                      label: AppLocalizations.get('sources_button', english),
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
