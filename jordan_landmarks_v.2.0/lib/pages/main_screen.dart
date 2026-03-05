import 'package:flutter/material.dart';
import 'home_page.dart';
import 'landmarks_page.dart';
import 'favourites_page.dart';
import 'quiz_page.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    settingsViewModel.addListener(updateSettings);
  }

  @override
  void dispose() {
    settingsViewModel.removeListener(updateSettings);
    super.dispose();
  }

  void updateSettings() {
    setState(() {});
  }

  List<Widget> pages = [
    HomePage(),
    LandmarksPage(),
    FavouritesPage(),
    QuizPage(),
  ];

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.get('nav_home', english),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: AppLocalizations.get('nav_landmarks', english),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: AppLocalizations.get('nav_favourites', english),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: AppLocalizations.get('nav_quiz', english),
          ),
        ],
      ),
    );
  }
}
