import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/auth/view/page/auth_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
  }

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
