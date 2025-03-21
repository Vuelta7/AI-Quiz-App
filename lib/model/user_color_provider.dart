import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userColorProvider = FutureProvider<Color>((ref) async {
  return await UserColorRepository().getUserColor();
});

class UserColorRepository {
  Future<Color> getUserColor() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null) return Colors.blue;

    try {
      if (await _isConnected()) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (doc.exists && doc.data()?['selectedColor'] != null) {
          String colorHex = doc.data()?['selectedColor'];
          await _saveToLocal(colorHex);
          return hexToColor(colorHex);
        }
      }

      return await _getFromLocal();
    } catch (e) {
      print("Error fetching user color: $e");
      return Colors.blue;
    }
  }

  Future<void> updateUserColor(String userId, String colorHex) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'selectedColor': colorHex});

      await _saveToLocal(colorHex);
    } catch (e) {
      print("Error updating user color: $e");
    }
  }

  Future<bool> _isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveToLocal(String colorHex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedColor', colorHex);
  }

  Future<Color> _getFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String colorHex = prefs.getString('selectedColor') ?? rgbToHex(Colors.blue);
    return hexToColor(colorHex);
  }
}

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
