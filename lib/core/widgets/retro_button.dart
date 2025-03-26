import 'package:flutter/material.dart';

Widget buildRetroButton(String text, Color color, VoidCallback? onPressed,
    {double width = double.infinity,
    IconData? icon,
    double? height,
    Color textColor = Colors.white}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadowColor: Colors.black,
        elevation: 6,
      ),
      icon: icon != null
          ? Icon(
              icon,
              size: 18,
              color: Colors.white,
            )
          : Container(),
      label: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 13,
          color: textColor,
        ),
      ),
    ),
  );
}
