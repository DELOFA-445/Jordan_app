import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'utils/app_localizations.dart';
import 'utils/http_overrides_stub.dart' if (dart.library.io) 'utils/http_overrides_io.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 * 1024 * 1024;

  await Hive.initFlutter();
  setupHttpOverrides();

  await Hive.openBox('settingsBox');
  await Hive.openBox('quizResultsBox');
  await Hive.openBox('ratingsBox');
  await Hive.openBox('favouritesBox');

  settingsViewModel.loadFromHive();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    settingsViewModel.addListener(updateMySettings);
  }

  @override
  void dispose() {
    settingsViewModel.removeListener(updateMySettings);
    super.dispose();
  }

  void updateMySettings() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;
    var title = AppLocalizations.get('app_title', english);
    
    TextDirection myDirection;
    if (english == true) {
      myDirection = TextDirection.ltr;
    } else {
      myDirection = TextDirection.rtl;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: settingsViewModel.getTheme(),
      builder: (context, child) {
        return Directionality(
          textDirection: myDirection,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(settingsViewModel.textScaleFactor),
            ),
            child: child!,
          ),
        );
      },
      home: SplashScreen(),
    );
  }
}
