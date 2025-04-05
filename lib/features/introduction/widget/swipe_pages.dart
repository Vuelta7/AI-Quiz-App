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

class StreakIntro extends StatelessWidget {
  const StreakIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 500,
            width: 600,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -120,
                  top: -40,
                  child: Lottie.asset('assets/effectbg.json', width: 600),
                ),
                Positioned(
                  left: -60,
                  top: 180,
                  child: Lottie.asset('assets/streakpet1.json', width: 300),
                ),
                Positioned(
                  left: 130,
                  top: 180,
                  child: Lottie.asset('assets/streakpet2.json', width: 300),
                ),
                Positioned(
                  left: 30,
                  top: 140,
                  child: Lottie.asset('assets/streakpet3.json', width: 300),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Take care of your streak pets by being the Streak Master!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'PressStart2P',
              ),
            ),
          )
        ],
      ),
    );
  }
}
