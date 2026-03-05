import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../viewmodels/quiz_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';
import 'settings_page.dart';

class QuizPage extends StatefulWidget {
  QuizPage({super.key});

  @override
  State<QuizPage> createState() {
    return _QuizPageState();
  }
}

class _QuizPageState extends State<QuizPage> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingsViewModel.addListener(updateSettings);
  }

  @override
  void dispose() {
    nameController.dispose();
    settingsViewModel.removeListener(updateSettings);
    super.dispose();
  }

  void updateSettings() {
    setState(() {});
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
          AppLocalizations.get('quiz_title', english),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 80, color: Colors.brown),
                SizedBox(height: 24),
                Text(
                  AppLocalizations.get('quiz_desc_1', english),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.get('quiz_desc_2', english),
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.get('optional_name', english),
                      hintText: AppLocalizations.get('enter_name', english),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    String? name = nameController.text;
                    if (name.trim() == '') {
                      name = null;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(userName: name),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text(
                    AppLocalizations.get('quiz_start', english),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  String? userName;

  QuizScreen({super.key, this.userName});

  @override
  State<QuizScreen> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends State<QuizScreen> {
  QuizViewModel vm = QuizViewModel();

  @override
  void initState() {
    super.initState();
    vm.addListener(updateVm);
    settingsViewModel.addListener(updateSettings);
  }

  void updateSettings() {
    vm.loadQuestions();
    setState(() {});
  }

  void updateVm() {
    setState(() {});
  }

  @override
  void dispose() {
    vm.removeListener(updateVm);
    settingsViewModel.removeListener(updateSettings);
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;
    var question = vm.getCurrentQuestion();

    var difficulty = question.difficulty;
    Color chipColor;
    String labelKey;

    if (difficulty == "easy") {
      chipColor = Colors.green;
      labelKey = 'difficulty_easy';
    } else if (difficulty == "medium") {
      chipColor = Colors.orange;
      labelKey = 'difficulty_medium';
    } else {
      chipColor = Colors.red;
      labelKey = 'difficulty_hard';
    }

    Widget difficultyChip = Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor, width: 1.5),
      ),
      child: Text(
        AppLocalizations.get(labelKey, english),
        style: TextStyle(
          color: chipColor.withValues(alpha: 0.9),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );

    String counterText = AppLocalizations.get('question_counter', english);
    counterText = counterText.replaceAll('{current}', (vm.currentQuestionIndex + 1).toString());
    counterText = counterText.replaceAll('{total}', vm.getQuestions().length.toString());

    List<Widget> choiceWidgets = [];
    for (var i = 0; i < question.choices.length; i++) {
      var isSelected = vm.selectedChoice == i;
      choiceWidgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              vm.selectChoice(i);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown.shade100 : Colors.grey.shade100,
                border: Border.all(
                  color: isSelected ? Colors.brown.shade600 : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? Colors.brown.shade600 : Colors.grey,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.choices[i],
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(counterText),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: vm.getProgress(),
                backgroundColor: Colors.brown.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.brown.shade600,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(height: 24),
              Row(children: [difficultyChip]),
              SizedBox(height: 16),
              Text(
                question.question,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              
              Column(
                children: choiceWidgets,
              ),

              SizedBox(height: 32),
              ElevatedButton(
                onPressed: vm.getHasSelectedChoice() == true
                    ? () {
                        vm.submitAnswer(() {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultsScreen(
                                questions: vm.getQuestions(),
                                userAnswers: vm.userAnswers,
                                score: vm.calculateScore(),
                                userName: widget.userName,
                              ),
                            ),
                          );
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  vm.getIsLastQuestion() == false
                      ? AppLocalizations.get('next', english)
                      : AppLocalizations.get('finish_quiz', english),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  List<QuizQuestion> questions;
  List<int?> userAnswers;
  int score;
  String? userName;

  ResultsScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.score,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    var english = settingsViewModel.isEnglish;

    IconData scoreIcon;
    Color scoreIconColor;
    String scoreMessage;

    if (score >= 4) {
      scoreIcon = Icons.emoji_events;
      scoreIconColor = Colors.amber;
      scoreMessage = AppLocalizations.get('excellent', english);
    } else if (score >= 2) {
      scoreIcon = Icons.thumb_up;
      scoreIconColor = Colors.brown;
      scoreMessage = AppLocalizations.get('good', english);
    } else {
      scoreIcon = Icons.refresh;
      scoreIconColor = Colors.grey;
      scoreMessage = AppLocalizations.get('try_again', english);
    }

    List<Widget> resultCards = [];
    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      var userAnswer = userAnswers[i];
      var isCorrect = userAnswer == question.correctIndex;

      resultCards.add(
        Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.question,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.blueGrey,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              AppLocalizations.get('explanation_title', english),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              question.explanation,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  AppLocalizations.get('close', english),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (!isCorrect && userAnswer != null)
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
                        Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.get('your_answer', english) + ' ' + question.choices[userAnswer],
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.get('correct_answer', english) + ' ' + question.choices[question.correctIndex],
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.get('quiz_result', english),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        scoreIcon,
                        size: 64,
                        color: scoreIconColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        score.toString() + ' / ' + questions.length.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        scoreMessage,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              Column(
                children: resultCards,
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await QuizViewModel.saveQuizResult(
                    score,
                    questions.length,
                    userName: userName,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.get('result_saved', english),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  AppLocalizations.get('save_result', english),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  AppLocalizations.get('back', english),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
