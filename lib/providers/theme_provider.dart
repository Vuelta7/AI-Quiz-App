import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = ThemeData.light();

  ThemeData get themeData => _themeData;

  void updateTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
