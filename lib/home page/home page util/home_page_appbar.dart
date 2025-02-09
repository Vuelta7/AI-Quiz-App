import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final Color color;

  const CustomAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'PressStart2P',
        ),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: getShade(color, 800),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
