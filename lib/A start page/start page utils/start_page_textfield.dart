import 'package:flutter/material.dart';

Widget buildRetroTextField(
  String label, {
  bool isPassword = false,
  required TextEditingController controller,
  String? Function(String?)? validator,
  FocusNode? focusNode,
  void Function(String)? onFieldSubmitted, // Add onFieldSubmitted parameter
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    cursorColor: Colors.black,
    focusNode: focusNode,
    onFieldSubmitted: onFieldSubmitted, // Use the onFieldSubmitted parameter
    style: const TextStyle(
      fontFamily: 'Arial',
      color: Color.fromARGB(255, 0, 0, 0),
      fontSize: 14,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'PressStart2P',
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 0, 0, 0),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 0, 0, 0),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 0, 0, 0),
          width: 3,
        ),
      ),
    ),
    validator: validator,
  );
}
