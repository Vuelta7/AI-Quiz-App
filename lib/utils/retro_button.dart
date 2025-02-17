import 'package:flutter/material.dart';

Widget buildRetroButton(String text, Color color, VoidCallback? onPressed,
    {double width = double.infinity, IconData? icon}) {
  return SizedBox(
    width: width,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 13,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    ),
  );
}
