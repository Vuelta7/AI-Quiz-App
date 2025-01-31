import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MasterIntroPage extends StatelessWidget {
  final Color backgroundColor;
  final String text1;
  final String text2;
  final String text3;

  static const style = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );

  const MasterIntroPage({
    super.key,
    required this.backgroundColor,
    required this.text1,
    required this.text2,
    required this.text3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Lottie.asset(
            'assets/digitalizequiz.json',
            fit: BoxFit.cover,
          ),
          const Padding(
            padding: EdgeInsets.all(24),
          ),
          Column(
            children: [
              Text(
                text1,
                style: style,
              ),
              Text(
                text2,
                style: style,
              ),
              Text(
                text3,
                style: style,
              ),
            ],
          )
        ],
      ),
    );
  }
}
