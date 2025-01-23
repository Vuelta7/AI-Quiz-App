import 'package:flutter/material.dart';
import 'package:learn_n/A%20start%20page/auth_screen.dart';
import 'package:learn_n/A%20start%20page/start%20page%20utils/start_page_button.dart';
import 'package:learn_n/A%20start%20page/start%20page%20utils/start_page_utils.dart';

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
              buildLogo(),
              buildTitleText('Learn-N'),
              const SizedBox(height: 40),
              buildRetroButton(
                'Register',
                Colors.black,
                () {
                  Navigator.push(context, AuthScreen.route(isLogin: false));
                },
              ),
              const SizedBox(height: 20),
              buildRetroButton(
                'Log In',
                Colors.black,
                () {
                  Navigator.push(context, AuthScreen.route(isLogin: true));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
