import 'package:flutter/material.dart';

Widget authTextFormField(
  String label, {
  bool isPassword = false,
  required TextEditingController controller,
  String? Function(String?)? validator,
  FocusNode? focusNode,
  void Function(String)? onFieldSubmitted,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    cursorColor: Colors.black,
    focusNode: focusNode,
    onFieldSubmitted: onFieldSubmitted,
    style: const TextStyle(
      fontFamily: 'Arial',
      color: Colors.black,
      fontSize: 14,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'PressStart2P',
        color: Colors.black,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 3,
        ),
      ),
    ),
    validator: validator,
  );
}
