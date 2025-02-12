import 'package:flutter/material.dart';

Color strengthenColor(Color color, double factor) {
  int r = (color.red * factor).clamp(0, 255).toInt();
  int g = (color.green * factor).clamp(0, 255).toInt();
  int b = (color.blue * factor).clamp(0, 255).toInt();
  return Color.fromARGB(color.alpha, r, g, b);
}

String rgbToHex(Color color) {
  return '${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}

Color hexToColor(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

Color getShade(Color color, int shade) {
  assert(shade >= 100 && shade <= 900 && shade % 100 == 0);
  final int r = color.red;
  final int g = color.green;
  final int b = color.blue;
  final double factor = (shade / 1000).clamp(0.0, 1.0);
  return Color.fromRGBO(
    (r * factor).toInt(),
    (g * factor).toInt(),
    (b * factor).toInt(),
    1,
  );
}

Color getTextColorForBackground(Color backgroundColor) {
  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
