import 'package:flutter/material.dart';

class myTheme extends ChangeNotifier {
  bool theme = false; //light theme
  void changeTheme() {
    theme = !theme;
    notifyListeners();
  }
}
