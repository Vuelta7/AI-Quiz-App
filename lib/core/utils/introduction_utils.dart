import 'package:flutter/material.dart';

Widget buildLogo([Color color = Colors.black]) {
  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      color,
      BlendMode.srcIn,
    ),
    child: Image.asset(
      'assets/logo_icon.png',
      height: 200,
      width: 200,
    ),
  );
}

Widget buildTitleText(String text,
    [Color color = Colors.black, double fontSize = 24]) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: 'PressStart2P',
      color: color,
      fontSize: fontSize,
      letterSpacing: 2.0,
      fontWeight: FontWeight.bold,
    ),
  );
}
