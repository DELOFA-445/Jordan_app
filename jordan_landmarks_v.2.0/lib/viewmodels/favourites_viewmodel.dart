import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FavouritesViewModel extends ChangeNotifier {
  Box getBox() {
    return Hive.box('favouritesBox');
  }

  List<String> getFavouritesList() {
    var box = getBox();
    var keys = box.get('keys');
    
    if (keys == null) {
      return [];
    }
    
    List<String> favList = [];
    for (var i = 0; i < keys.length; i++) {
      favList.add(keys[i].toString());
    }
    
    return favList;
  }

  bool isFavourite(String titleKey) {
    var list = getFavouritesList();
    for (var i = 0; i < list.length; i++) {
      if (list[i] == titleKey) {
        return true;
      }
    }
    return false;
  }

  void toggleFavourite(String titleKey) {
    var currentList = getFavouritesList();
    var found = false;
    
    for (var i = 0; i < currentList.length; i++) {
      if (currentList[i] == titleKey) {
        found = true;
      }
    }
    
    if (found == true) {
      currentList.remove(titleKey);
    } else {
      currentList.add(titleKey);
    }
    
    var box = getBox();
    box.put('keys', currentList);
    notifyListeners();
  }

  void removeFavourite(String titleKey) {
    var currentList = getFavouritesList();
    currentList.remove(titleKey);
    
    var box = getBox();
    box.put('keys', currentList);
    notifyListeners();
  }
}

var favouritesViewModel = FavouritesViewModel();
