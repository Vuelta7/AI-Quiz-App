import 'package:flutter/material.dart';

class LearnNIcon extends StatelessWidget {
  final IconData icon;
  final Offset offset;
  final Color color;
  final Color shadowColor;
  final double size;

  const LearnNIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.shadowColor,
    this.offset = const Offset(2, 2),
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: size,
      shadows: [
        Shadow(
          offset: offset,
          color: shadowColor,
          blurRadius: 0,
        ),
      ],
    );
  }
}
