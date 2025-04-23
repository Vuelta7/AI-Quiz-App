import 'package:flutter/material.dart';

Widget buildLogo([Color color = Colors.black]) {
  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      color,
      BlendMode.srcIn,
    ),
    child: Image.asset(
      'assets/images/logo_icon.png',
      height: 200,
      width: 200,
    ),
  );
}
