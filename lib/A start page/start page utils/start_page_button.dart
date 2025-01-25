import 'package:flutter/material.dart';

Widget buildRetroButton(String text, Color color, VoidCallback? onPressed,
    {width = double.infinity}) {
  return SizedBox(
    width: width,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 16,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    ),
  );
}
