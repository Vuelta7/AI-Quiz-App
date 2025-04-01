import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';
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
              buildTitleText('Learn-N'),
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
