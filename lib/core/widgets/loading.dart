import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Lottie.asset('assets/loading.json'),
            const Text(
              'Cooking',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'PressStart2P'),
            ),
          ],
        ),
      ),
    );
  }
}
