import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:learn_n/home%20page/home_main.dart';
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
        title: const Text('Select Theme Color'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            ElevatedButton(
              onPressed: () async {
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
              child: const Text('Change Theme Color'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: List.generate(9, (index) {
                  final shade = (index + 1) * 100;
                  final color = getShade(selectedColor, shade);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                    ),
                    title: Text('Shade $shade'),
                    subtitle: Text(
                      'Text color: ${getTextColorForBackground(color) == Colors.black ? 'Black' : 'White'}',
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
