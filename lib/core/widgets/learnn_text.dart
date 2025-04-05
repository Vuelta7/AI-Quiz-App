import 'package:flutter/material.dart';

class LearnNText extends StatelessWidget {
  final String text;
  final double fontSize;
  final String font;
  final Color color;
  final Offset offset;
  final Color backgroundColor;
  const LearnNText({
    super.key,
    required this.fontSize,
    required this.text,
    required this.font,
    required this.color,
    this.offset = const Offset(2, 2),
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: font,
        fontSize: fontSize,
        color: color,
        shadows: [
          Shadow(
            offset: offset,
            color: backgroundColor,
            blurRadius: 0,
          ),
        ],
      ),
    );
  }
}
