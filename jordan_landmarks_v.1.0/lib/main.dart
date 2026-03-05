import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MySettings extends ChangeNotifier {
  String contrast = "medium";
  double scale = 1.0;
  bool dark = false;
  bool sound = true;

  void changeContrast(String v) {
    contrast = v;
    notifyListeners();
  }

  void changeScale(double v) {
    scale = v;
    notifyListeners();
  }

  void changeDark(bool v) {
    dark = v;
    notifyListeners();
  }

  void changeSound(bool v) {
    sound = v;
    notifyListeners();
  }

  ThemeData getTheme() {
    Color seed;
    if (contrast == "low") {
      seed = Colors.brown.shade200;
    } else if (contrast == "high") {
      seed = Colors.brown.shade900;
    } else {
      seed = Colors.brown;
    }

    double cLevel;
    if (contrast == "high") {
      cLevel = 1.0;
    } else if (contrast == "low") {
      cLevel = -1.0;
    } else {
      cLevel = 0.0;
    }

    Brightness b;
    if (dark) {
      b = Brightness.dark;
    } else {
      b = Brightness.light;
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: b,
        contrastLevel: cLevel,
      ),
      useMaterial3: true,
    );
  }
}

final settings = MySettings();

void doSound(String path) async {
  if (!settings.sound) return;
  var p = AudioPlayer();
  p.audioCache.prefix = '';
  await p.play(AssetSource(path));
}

void main() {
  runApp(JordanLandmarksApp());
}


class JordanLandmarksApp extends StatefulWidget {
  const JordanLandmarksApp({super.key});
  @override
  State<JordanLandmarksApp> createState() {
    return _JordanLandmarksAppState();
  }
}

class _JordanLandmarksAppState extends State<JordanLandmarksApp> {
  @override
  void initState() {
    super.initState();
    settings.addListener(_update);
  }

  @override
  void dispose() {
    settings.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jordan Landmarks',
      theme: settings.getTheme(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(settings.scale),
            ),
            child: child!,
          ),
        );
      },
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final _pages = [
    HomePage(),
    LandmarksPage(),
    QuizPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) {
          setState(() { _idx = i; });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'المعالم'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'الاختبار'),
        ],
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _ctrl;
  bool _muted = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _setupVid();
  }

  void _setupVid() async {
    _videoFailed = false;
    _ctrl = VideoPlayerController.networkUrl(
      Uri.parse('https://ia902805.us.archive.org/17/items/intro_video_360p/intro_video_480p.mp4'),
    );

    try {
      await _ctrl.initialize();
      setState(() {});
    } catch (e) {
      setState(() {
        _videoFailed = true;
      });
    }

    _ctrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(() {});
    _ctrl.dispose();
    super.dispose();
  }

  void _retry() {
    _ctrl.dispose();
    setState(() {
      _setupVid();
    });
  }

  void _skip(Duration d) async {
    var pos = await _ctrl.position;
    if (pos != null) {
      await _ctrl.seekTo(pos + d);
    }
  }

  void _setVol(double vol) {
    setState(() {
      _ctrl.setVolume(vol);
      _muted = vol == 0;
    });
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      if (_muted) {
        _ctrl.setVolume(0.0);
      } else {
        _ctrl.setVolume(1.0);
      }
    });
  }

  Widget _buildVideoArea() {
    if (_videoFailed) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('تعذر تحميل الفيديو', style: TextStyle(fontSize: 16)),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: Icon(Icons.refresh),
                label: Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_ctrl.value.isInitialized) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    IconData volIcon;
    if (_muted || _ctrl.value.volume == 0) {
      volIcon = Icons.volume_off;
    } else {
      volIcon = Icons.volume_up;
    }

    IconData playIcon;
    if (_ctrl.value.isPlaying) {
      playIcon = Icons.pause_circle_filled;
    } else {
      playIcon = Icons.play_circle_fill;
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _ctrl.value.aspectRatio,
          child: VideoPlayer(_ctrl),
        ),
        VideoProgressIndicator(
          _ctrl,
          allowScrubbing: true,
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(volIcon),
                onPressed: _toggleMute,
              ),
              Expanded(
                child: Slider(
                  value: _muted ? 0.0 : _ctrl.value.volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: _setVol,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.forward_10),
                onPressed: () {
                  _skip(Duration(seconds: 10));
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(playIcon, size: 50),
                onPressed: () {
                  setState(() {
                    if (_ctrl.value.isPlaying) {
                      _ctrl.pause();
                    } else {
                      _ctrl.play();
                    }
                  });
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.replay_10),
                onPressed: () {
                  _skip(Duration(seconds: -10));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return SettingsPage();
              }));
            },
          ),
        ],
        title: Text('الأردن'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: _buildVideoArea(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'مرحبا بك في الأردن، اكتشف الجمال والتاريخ. في هذا التطبيق سوف تتعرف على اشهر و ابرز المعالم السياحية التي يجب عليك زيارتها',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MyNetworkImg extends StatefulWidget {
  final String url;
  const MyNetworkImg({super.key, required this.url});
  @override
  State<MyNetworkImg> createState() {
    return _MyNetworkImgState();
  }
}

class _MyNetworkImgState extends State<MyNetworkImg> {
  Key _k = UniqueKey();

  void _retry() {
    setState(() { _k = UniqueKey(); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          key: _k,
          imageUrl: widget.url,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (ctx, url) {
            return SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorWidget: (ctx, url, err) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 36, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('تعذر تحميل الصورة', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: Icon(Icons.refresh, size: 18),
                      label: Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class LandmarksPage extends StatelessWidget {
  const LandmarksPage({super.key});

  void _openMap(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return SettingsPage();
              }));
            },
          ),
        ],
        title: Text('المعالم'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _card(
              context,
              'البتراء',
              'البتراء، المعروفة أيضاً بالمدينة الوردية، هي موقع أثري تاريخي يقع في جنوب الأردن. '
              'تأسست في القرن الرابع قبل الميلاد كعاصمة لمملكة الأنباط. '
              'تشتهر بعمارتها المنحوتة في الصخر الوردي وهي واحدة من عجائب الدنيا السبع الجديدة '
              'وأحد مواقع التراث العالمي لليونسكو.',
              'https://ia800707.us.archive.org/10/items/jarash_1/petra_1.webp',
              'https://ia800707.us.archive.org/10/items/jarash_1/petra_2.webp',
              'https://www.google.com/maps/place/%D8%A7%D9%84%D8%A8%D8%AA%D8%B1%D8%A7%E2%80%AD/@30.3284544,35.4443622,15z/data=!4m6!3m5!1s0x15016ef1703b6071:0x199bf908679a2291!8m2!3d30.3284544!4d35.4443622!16zL20vMGM3enk?entry=ttu&g_ep=EgoyMDI2MDIyNC4wIKXMDSoASAFQAw%3D%3D',
              ['مناسب للعائلات', 'صيفي', 'ثلاث ساعات من عمان'],
            ),
            SizedBox(height: 24),
            _card(
              context,
              'البحر الميت',
              'البحر الميت هو أخفض نقطة على سطح الأرض، حيث ينخفض عن مستوى سطح البحر بحوالي 430 متراً. '
              'يقع على الحدود بين الأردن وفلسطين، ويشتهر بمياهه شديدة الملوحة التي تمكن الزوار من الطفو بسهولة. '
              'يُعد وجهة علاجية وسياحية عالمية بفضل طينه الغني بالمعادن ومياهه ذات الخصائص العلاجية.',
              'https://ia800707.us.archive.org/10/items/jarash_1/Dead_Sea_1.webp',
              'https://ia800707.us.archive.org/10/items/jarash_1/Dead_Sea_2.webp',
              'https://www.google.com/maps/place/Dead+Sea/@31.5,35.5,10z',
              ['مناسب للعائلات', 'صيفي', 'ساعة من عمان'],
            ),
            SizedBox(height: 24),
            _card(
              context,
              'وادي رم',
              'وادي رم، المعروف أيضاً بوادي القمر، هو وادي صحراوي خلاب يقع في جنوب الأردن. '
              'يتميز بتكويناته الصخرية الرملية الحمراء الشاهقة وأقواسه الطبيعية ومنحدراته الضخمة. '
              'يُعد موقع تراث عالمي لليونسكو واستخدم كموقع تصوير للعديد من الأفلام العالمية مثل فيلم لورنس العرب والمريخ.',
              'https://ia800707.us.archive.org/10/items/jarash_1/wadi_rum_1.webp',
              'https://ia800707.us.archive.org/10/items/jarash_1/wadi_rum_2.webp',
              'https://www.google.com/maps/place/%D9%88%D8%A7%D8%AF%D9%8A+%D8%B1%D9%85%E2%80%AD/@29.5721,35.4205,12z/data=!4m6!3m5!1s0x150093a5d3b537b3:0xe9885592958b5d07!8m2!3d29.555872!4d35.4076008!16zL20vMDU3N3F4?entry=ttu&g_ep=EgoyMDI2MDIyNC4wIKXMDSoASAFQAw%3D%3D',
              ['مغامرات', 'تخييم', 'أربع ساعات من عمان'],
            ),
            SizedBox(height: 24),
            _card(
              context,
              'جرش',
              'جرش هي واحدة من أفضل المدن الرومانية المحفوظة في العالم، وتقع في شمال الأردن. '
              'تضم آثاراً رومانية مذهلة تشمل الساحة البيضاوية وشارع الأعمدة ومعبد أرتميس والمدرج الجنوبي. '
              'تستضيف المدينة سنوياً مهرجان جرش للثقافة والفنون، وهو من أبرز المهرجانات الثقافية في المنطقة.',
              'https://ia800707.us.archive.org/10/items/jarash_1/jarash_1.webp',
              'https://ia800707.us.archive.org/10/items/jarash_1/jerash_2.webp',
              'https://www.google.com/maps/place/%D8%AC%D8%B1%D8%B4%E2%80%AD/@32.2746,35.8912,14z/data=!4m6!3m5!1s0x151c87571e47446d:0x34472731494f103b!8m2!3d32.2746!4d35.8912!16zL20vMDR0c3Fj?entry=ttu&g_ep=EgoyMDI2MDIyNC4wIKXMDSoASAFQAw%3D%3D',
              ['تاريخي', 'مناسب للعائلات', 'ساعة من عمان'],
            ),
            SizedBox(height: 24),
            _card(
              context,
              'العقبة',
              'العقبة هي المدينة الساحلية الوحيدة في الأردن، وتقع على شاطئ البحر الأحمر في أقصى جنوب البلاد. '
              'تشتهر بشعابها المرجانية الخلابة ومياهها الصافية التي تجعلها وجهة مثالية للغوص والرياضات المائية. '
              'تتمتع بتاريخ عريق يعود لأكثر من 5500 عام وتعد منطقة اقتصادية حرة وبوابة الأردن البحرية.',
              'https://ia800707.us.archive.org/10/items/jarash_1/aqaba_1.webp',
              'https://ia800707.us.archive.org/10/items/jarash_1/aqaba_2.webp',
              'https://www.google.com/maps/place/Aqaba/@29.5267,35.0078,13z',
              ['شاطئ', 'غوص', 'أربع ساعات من عمان'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, String info, String img1, String img2, String mapUrl, List<String> tags) {
    List<Widget> tagWidgets = [];
    for (var t in tags) {
      tagWidgets.add(
        Chip(
          label: Text(t, style: TextStyle(color: Colors.white, fontSize: 13)),
          backgroundColor: Colors.brown.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.brown.shade700,
            child: Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(info, style: TextStyle(fontSize: 16, height: 1.6)),
          ),
          MyNetworkImg(url: img1),
          SizedBox(height: 12),
          MyNetworkImg(url: img2),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _openMap(mapUrl);
              },
              icon: Icon(Icons.map),
              label: Text('عرض على خرائط جوجل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tagWidgets,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}


class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return SettingsPage();
              }));
            },
          ),
        ],
        title: Text('الاختبار'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 80, color: Colors.brown),
            SizedBox(height: 24),
            Text(
              'اختبر معلوماتك عن معالم الاردن!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text('5 أسئلة - نقطة واحدة لكل سؤال', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return QuizScreen();
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('!ابدأ الاختبار'),
            ),
          ],
        ),
      ),
    );
  }
}


class Question {
  String q;
  List<String> choices;
  int answer;
  Question(this.q, this.choices, this.answer);
}


class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends State<QuizScreen> {
  final _questions = [
    Question('ما هو الاسم الآخر لمدينة البتراء؟', ['المدينة البيضاء', 'المدينة الوردية', 'المدينة الذهبية', 'المدينة الزرقاء'], 1),
    Question('كم ينخفض البحر الميت عن مستوى سطح البحر تقريباً؟', ['200 متر', '330 متر', '430 متر', '530 متر'], 2),
    Question('ما هو الفيلم الشهير الذي تم تصويره في وادي رم؟', ['هاري بوتر', 'لورنس العرب', 'سيد الخواتم', 'حرب النجوم'], 1),
    Question('ما هي الحضارة التي بنت مدينة جرش؟', ['الفرعونية', 'اليونانية', 'الرومانية', 'العثمانية'], 2),
    Question('على أي بحر تقع مدينة العقبة؟', ['البحر المتوسط', 'البحر الميت', 'البحر الأحمر', 'بحر العرب'], 2),
  ];

  int _qIndex = 0;
  int? _picked;
  final List<int?> _answers = [];

  void _next() {
    _answers.add(_picked);

    bool correct = _picked == _questions[_qIndex].answer;
    if (correct) {
      doSound('lib/assets/Clapping.wav');
    }

    if (_qIndex < _questions.length - 1) {
      setState(() {
        _qIndex++;
        _picked = null;
      });
    } else {
      int score = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (_answers[i] == _questions[i].answer) score++;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) {
          return ResultsScreen(_questions, _answers, score);
        }),
      );
    }
  }

  Widget _buildChoice(Question q, int i) {
    bool selected = _picked == i;

    Color bgColor;
    Color borderColor;
    if (selected) {
      bgColor = Colors.brown.shade100;
      borderColor = Colors.brown.shade600;
    } else {
      bgColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade300;
    }

    IconData icon;
    Color iconColor;
    if (selected) {
      icon = Icons.radio_button_checked;
      iconColor = Colors.brown.shade600;
    } else {
      icon = Icons.radio_button_off;
      iconColor = Colors.grey;
    }

    FontWeight weight;
    if (selected) {
      weight = FontWeight.bold;
    } else {
      weight = FontWeight.normal;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() { _picked = i; });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  q.choices[i],
                  style: TextStyle(fontSize: 17, fontWeight: weight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var q = _questions[_qIndex];

    List<Widget> choiceWidgets = [];
    for (int i = 0; i < q.choices.length; i++) {
      choiceWidgets.add(_buildChoice(q, i));
    }

    String btnText;
    if (_qIndex < _questions.length - 1) {
      btnText = 'التالي';
    } else {
      btnText = 'إنهاء الاختبار';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('سؤال ${_qIndex + 1} من ${_questions.length}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_qIndex + 1) / _questions.length,
              backgroundColor: Colors.brown.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 32),
            Text(q.q, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            ...choiceWidgets,
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _picked != null ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(btnText),
            ),
          ],
        ),
      ),
    );
  }
}


class ResultsScreen extends StatelessWidget {
  final List<Question> questions;
  final List<int?> answers;
  final int score;

  const ResultsScreen(this.questions, this.answers, this.score, {super.key});

  IconData _getScoreIcon() {
    if (score >= 4) return Icons.emoji_events;
    if (score >= 2) return Icons.thumb_up;
    return Icons.refresh;
  }

  Color _getScoreColor() {
    if (score >= 4) return Colors.amber;
    if (score >= 2) return Colors.brown;
    return Colors.grey;
  }

  String _getScoreMsg() {
    if (score >= 4) return 'ممتاز! معلوماتك رائعة!';
    if (score >= 2) return 'جيد! يمكنك التحسن أكثر.';
    return 'حاول مرة أخرى!';
  }

  Widget _buildQuestionResult(int i) {
    var q = questions[i];
    var userAns = answers[i];
    bool correct = userAns == q.answer;

    IconData icon;
    Color iconColor;
    if (correct) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else {
      icon = Icons.cancel;
      iconColor = Colors.red;
    }

    List<Widget> items = [];

    items.add(
      Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          SizedBox(width: 8),
          Expanded(
            child: Text(q.q, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    items.add(SizedBox(height: 12));

    if (!correct && userAns != null) {
      items.add(
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.close, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'إجابتك: ${q.choices[userAns]}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    items.add(
      Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'الإجابة الصحيحة: ${q.choices[q.answer]}',
                style: TextStyle(color: Colors.green.shade700, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> questionCards = [];
    for (int i = 0; i < questions.length; i++) {
      questionCards.add(_buildQuestionResult(i));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('النتيجة'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(_getScoreIcon(), size: 64, color: _getScoreColor()),
                    SizedBox(height: 16),
                    Text(
                      '$score / ${questions.length}',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(_getScoreMsg(), style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ...questionCards,
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('العودة'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    settings.addListener(_update);
  }

  @override
  void dispose() {
    settings.removeListener(_update);
    super.dispose();
  }

  void _update() { setState(() {}); }

  String _cLabel(String level) {
    if (level == "low") return 'منخفض';
    if (level == "medium") return 'متوسط';
    return 'عالي';
  }

  String _sizeText(double f) {
    return '${(f * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    IconData modeIcon;
    if (settings.dark) {
      modeIcon = Icons.dark_mode;
    } else {
      modeIcon = Icons.light_mode;
    }

    IconData soundIcon;
    if (settings.sound) {
      soundIcon = Icons.volume_up;
    } else {
      soundIcon = Icons.volume_off;
    }

    String darkText;
    if (settings.dark) {
      darkText = 'مفعل';
    } else {
      darkText = 'معطل';
    }

    String soundText;
    if (settings.sound) {
      soundText = 'مفعل';
    } else {
      soundText = 'معطل';
    }

    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contrast),
                      SizedBox(width: 8),
                      Text('التباين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: settings.contrast,
                    onChanged: (v) {
                      if (v != null) {
                        settings.changeContrast(v);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(_cLabel("low")),
                          value: "low",
                        ),
                        RadioListTile<String>(
                          title: Text(_cLabel("medium")),
                          value: "medium",
                        ),
                        RadioListTile<String>(
                          title: Text(_cLabel("high")),
                          value: "high",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields),
                      SizedBox(width: 8),
                      Text('حجم النص', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('أ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: settings.scale,
                          min: 1.0,
                          max: 2.0,
                          divisions: 4,
                          label: _sizeText(settings.scale),
                          onChanged: (v) {
                            settings.changeScale(v);
                          },
                        ),
                      ),
                      Text('أ', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  Center(
                    child: Text(_sizeText(settings.scale), style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: Icon(modeIcon),
              title: Text('الوضع الداكن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(darkText),
              value: settings.dark,
              onChanged: (v) {
                settings.changeDark(v);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: Icon(soundIcon),
              title: Text('الصوت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(soundText),
              value: settings.sound,
              onChanged: (v) {
                settings.changeSound(v);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.star_rate),
              title: Text('قيم التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('شاركنا رأيك'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return RateAppPage();
                }));
              },
            ),
          ),
        ],
      ),
    );
  }
}


class RateAppPage extends StatefulWidget {
  const RateAppPage({super.key});
  @override
  State<RateAppPage> createState() {
    return _RateAppPageState();
  }
}

class _RateAppPageState extends State<RateAppPage> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار تقييم')),
      );
      return;
    }

    var confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('حفظ البيانات'),
          content: Text('سيتم حفظ تقييمك وتعليقك محلياً على جهازك. هل توافق على ذلك؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text('موافق'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_rating', _rating);
    await prefs.setString('app_comment', _commentCtrl.text);

    if (_rating >= 4) {
      doSound('lib/assets/high_rate.wav');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('شكراً لك! تم حفظ تقييمك بنجاح.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData starIcon;
      Color starColor;
      if (i <= _rating) {
        starIcon = Icons.star;
        starColor = Colors.amber;
      } else {
        starIcon = Icons.star_border;
        starColor = Colors.grey;
      }

      stars.add(
        GestureDetector(
          onTap: () {
            setState(() { _rating = i; });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(starIcon, size: 48, color: starColor),
          ),
        ),
      );
    }

    String ratingText = '';
    if (_rating > 0) {
      ratingText = '$_rating / 5';
    }

    return Scaffold(
      appBar: AppBar(title: Text('قيم التطبيق')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.rate_review, size: 64, color: Colors.brown),
            SizedBox(height: 16),
            Text(
              'كيف تقيم تجربتك مع التطبيق؟',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: stars,
            ),
            SizedBox(height: 8),
            Text(ratingText, style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 32),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'تعليق (اختياري)',
                hintText: 'شاركنا ملاحظاتك...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('إرسال التقييم'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
