import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/home/home_main.dart';
import 'package:lottie/lottie.dart';

class ThemesPage extends ConsumerStatefulWidget {
  const ThemesPage({super.key});

  @override
  _ThemesPageState createState() => _ThemesPageState();
}

class _ThemesPageState extends ConsumerState<ThemesPage> {
  Future<void> updateUserColor(String userId, String colorHex) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'selectedColor': colorHex});
      await UserColorRepository().saveUserColor(colorHex);
    } catch (e) {
      print('Error updating user color: $e');
    }
  }

  void onColorChanged(Color color) {
    ref.read(userColorProvider.notifier).state = color;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = ref.watch(userColorProvider);

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
                final userId = ref.watch(userIdProvider);
                String colorHex = rgbToHex(selectedColor);
                await updateUserColor(userId!, colorHex);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeMain(),
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
