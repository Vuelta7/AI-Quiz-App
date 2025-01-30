import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset('assets/streakpet1.json', height: 200),
        const Text('Streak'),
      ],
    );
  }
}
