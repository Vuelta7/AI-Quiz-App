import 'package:flutter/material.dart';
import 'package:learn_n/start%20page/auth_page.dart';
import 'package:learn_n/start%20page/start%20page%20utils/start_page_button.dart';
import 'package:learn_n/start%20page/start%20page%20utils/start_page_utils.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
