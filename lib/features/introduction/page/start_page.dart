import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/widgets/learnn_logo.dart';
import 'package:learn_n/core/widgets/learnn_text.dart';
import 'package:learn_n/core/widgets/retro_button.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildLogo(),
              const LearnNText(
                fontSize: 30,
                text: 'Learn-N',
                font: 'PressStart2P',
                color: Colors.black,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 40),
              buildRetroButton(
                'Register',
                Colors.black,
                () {
                  context.go('/register');
                },
              ),
              const SizedBox(height: 15),
              buildRetroButton(
                'Log In',
                Colors.black,
                () {
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
