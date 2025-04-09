import 'package:flutter/material.dart';

Widget buildTile(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap,
  textIconColor,
) {
  return ListTile(
    leading: Icon(
      icon,
      color: textIconColor,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: textIconColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    onTap: onTap,
  );
}
