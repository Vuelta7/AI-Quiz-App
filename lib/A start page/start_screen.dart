import 'package:flutter/material.dart';
import 'package:learn_n/A%20start%20page/login_screen.dart';
import 'package:learn_n/A%20start%20page/register_screen.dart';
import 'package:learn_n/util.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
              Image.asset(
                'assets/logo_icon.png',
                height: 200,
                width: 200,
              ),
              const Text(
                'Learn-N',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.black,
                  fontSize: 24,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: buildRetroButton(
                  'Register',
                  Colors.black,
                  () {
                    Navigator.push(context, SignupScreen.route());
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: buildRetroButton(
                  'Log In',
                  Colors.black,
                  () {
                    Navigator.push(context, LoginScreen.route());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
