import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/model/user_color_provider.dart';
import 'package:learn_n/view/home/home_main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  _ThemesPageState createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  Color selectedColor = Colors.blue;

  Future<void> updateUserColor(String userId, String colorHex) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'selectedColor': colorHex});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedColor', colorHex);
    } catch (e) {
      print('Error updating user color: $e');
    }
  }

  void onColorChanged(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Theme Color',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Lottie.asset('assets/theme.json'),
            ColorPicker(
              pickersEnabled: const {
                ColorPickerType.wheel: true,
              },
              color: selectedColor,
              onColorChanged: onColorChanged,
              heading: const Text('Select color'),
              subheading: const Text('Select a different shade'),
            ),
            const SizedBox(height: 20),
            buildRetroButton(
              'Change Theme Color',
              selectedColor,
              () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String userId = prefs.getString('userId') ?? '';
                String colorHex = rgbToHex(selectedColor);
                await updateUserColor(userId, colorHex);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeMain(
                      userId: userId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
