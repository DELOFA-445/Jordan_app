import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/app_utils.dart';

class RateAppViewModel extends ChangeNotifier {
  int rating = 0;
  var commentController = TextEditingController();

  void setRating(int starIndex) {
    rating = starIndex;
    notifyListeners();
  }

  saveRating() async {
    var box = Hive.box('ratingsBox');
    await box.put('app_rating', rating);
    await box.put('app_comment', commentController.text);

    if (rating >= 4) {
      playSound('lib/assets/sounds/high_rate.wav');
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
