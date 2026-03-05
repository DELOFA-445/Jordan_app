import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/quiz_question.dart';
import '../utils/app_utils.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/app_localizations.dart';

class QuizViewModel extends ChangeNotifier {
  int currentQuestionIndex = 0;
  int? selectedChoice;
  List<int?> userAnswers = [];

  List<QuizQuestion> getQuestions() {
    var english = settingsViewModel.isEnglish;
    return [
      QuizQuestion(
        AppLocalizations.get('q1_q', english),
        [
          AppLocalizations.get('q1_c0', english),
          AppLocalizations.get('q1_c1', english),
          AppLocalizations.get('q1_c2', english),
          AppLocalizations.get('q1_c3', english),
        ],
        1,
        "easy",
        AppLocalizations.get('q1_exp', english),
      ),
      QuizQuestion(
        AppLocalizations.get('q2_q', english),
        [
          AppLocalizations.get('q2_c0', english),
          AppLocalizations.get('q2_c1', english),
          AppLocalizations.get('q2_c2', english),
          AppLocalizations.get('q2_c3', english),
        ],
        2,
        "medium",
        AppLocalizations.get('q2_exp', english),
      ),
      QuizQuestion(
        AppLocalizations.get('q3_q', english),
        [
          AppLocalizations.get('q3_c0', english),
          AppLocalizations.get('q3_c1', english),
          AppLocalizations.get('q3_c2', english),
          AppLocalizations.get('q3_c3', english),
        ],
        1,
        "medium",
        AppLocalizations.get('q3_exp', english),
      ),
      QuizQuestion(
        AppLocalizations.get('q4_q', english),
        [
          AppLocalizations.get('q4_c0', english),
          AppLocalizations.get('q4_c1', english),
          AppLocalizations.get('q4_c2', english),
          AppLocalizations.get('q4_c3', english),
        ],
        2,
        "hard",
        AppLocalizations.get('q4_exp', english),
      ),
      QuizQuestion(
        AppLocalizations.get('q5_q', english),
        [
          AppLocalizations.get('q5_c0', english),
          AppLocalizations.get('q5_c1', english),
          AppLocalizations.get('q5_c2', english),
          AppLocalizations.get('q5_c3', english),
        ],
        2,
        "easy",
        AppLocalizations.get('q5_exp', english),
      ),
    ];
  }

  QuizQuestion getCurrentQuestion() {
    return getQuestions()[currentQuestionIndex];
  }

  double getProgress() {
    return (currentQuestionIndex + 1) / getQuestions().length;
  }

  bool getHasSelectedChoice() {
    if (selectedChoice != null) {
      return true;
    } else {
      return false;
    }
  }

  bool getIsLastQuestion() {
    if (currentQuestionIndex >= getQuestions().length - 1) {
      return true;
    } else {
      return false;
    }
  }

  void selectChoice(int index) {
    selectedChoice = index;
    notifyListeners();
  }

  void submitAnswer(VoidCallback onQuizFinished) {
    userAnswers.add(selectedChoice);

    var isCorrect = false;
    if (selectedChoice == getCurrentQuestion().correctIndex) {
      isCorrect = true;
    }

    if (isCorrect == true) {
      playSound('lib/assets/sounds/Clapping.wav');
    }

    if (getIsLastQuestion() == false) {
      currentQuestionIndex = currentQuestionIndex + 1;
      selectedChoice = null;
      notifyListeners();
    } else {
      onQuizFinished();
    }
  }

  int calculateScore() {
    var score = 0;
    var allQuestions = getQuestions();
    for (var i = 0; i < allQuestions.length; i++) {
      if (userAnswers[i] == allQuestions[i].correctIndex) {
        score = score + 1;
      }
    }
    return score;
  }

  void loadQuestions() {
    notifyListeners();
  }

  static saveQuizResult(int score, int total, {String? userName}) async {
    var box = Hive.box('quizResultsBox');
    await box.put('latest_quiz_score', score);
    await box.put('latest_quiz_total', total);
    
    if (userName != null) {
      if (userName.trim().isNotEmpty) {
        await box.put('latest_quiz_name', userName.trim());
      } else {
        await box.delete('latest_quiz_name');
      }
    } else {
      await box.delete('latest_quiz_name');
    }
  }
}
