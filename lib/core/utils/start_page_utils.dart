import 'package:flutter/material.dart';
import 'package:learn_n/view/auth/auth_page.dart';

Widget buildLogo() {
  return ColorFiltered(
    colorFilter: const ColorFilter.mode(
      Colors.white,
      BlendMode.srcIn,
    ),
    child: Image.asset(
      'assets/logo_icon.png',
      height: 200,
      width: 200,
    ),
  );
}

Widget buildTitleText(String text, {double fontSize = 24}) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: 'PressStart2P',
      color: Colors.white,
      fontSize: fontSize,
      letterSpacing: 2.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildGestureDetector(BuildContext context, {required bool isLogin}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, AuthScreen.route(isLogin: !isLogin));
    },
    child: RichText(
      text: TextSpan(
        text:
            isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
        style: Theme.of(context).textTheme.titleMedium,
        children: [
          TextSpan(
            text: isLogin ? 'Register' : 'Login',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    ),
  );
}
