import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.purple,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Lottie.asset(
            'assets/digitalizequiz.json',
            fit: BoxFit.cover,
          ),
          const Text(
            "Welcome to Learn-N! Learn smarter with Active Recall and digitalized quizzes!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'PressStart2P',
            ),
          )
        ],
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Lottie.asset('assets/fire.json'),
          const Text(
            "Become a productivity master and be an egoist to reach Rank 1!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'PressStart2P',
            ),
          )
        ],
      ),
    );
  }
}
