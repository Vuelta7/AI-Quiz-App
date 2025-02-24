import 'package:flutter/material.dart';

ThemeData learnNThemes = ThemeData(
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionColor: Color.fromRGBO(255, 255, 255, 0.5),
    selectionHandleColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      fontFamily: 'PressStart2P',
      color: Colors.white,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.white,
        width: 2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.white,
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.white,
        width: 3,
      ),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    shape: StadiumBorder(),
    backgroundColor: Colors.white,
    contentTextStyle: TextStyle(
      color: Colors.black,
    ),
    behavior: SnackBarBehavior.floating,
  ),
);
