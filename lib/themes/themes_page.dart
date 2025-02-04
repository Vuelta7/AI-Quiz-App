import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/home%20page/home_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorUtils {
  static Color getShade(Color color, int shade) {
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
}

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  _ThemesPageState createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  Color selectedColor = Colors.blue;

  void onColorChanged(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
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
                String userId = prefs.getString('user_id') ?? 'default_user_id';
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
                  final color = ColorUtils.getShade(selectedColor, shade);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                    ),
                    title: Text('Shade $shade'),
                    subtitle: Text(
                      'Text color: ${_getTextColorForBackground(color) == Colors.black ? 'Black' : 'White'}',
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
