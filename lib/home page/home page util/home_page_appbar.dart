import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  Future<Color> getSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('selectedColor') ?? Colors.blue.value;
    return Color(colorValue);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color>(
      future: getSelectedColor(),
      builder: (context, snapshot) {
        final selectedColor = snapshot.data ?? Colors.blue;
        return AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'PressStart2P',
            ),
          ),
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: getShade(selectedColor, 800),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: leading,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
