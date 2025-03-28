import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget buildGestureDetector(BuildContext context, {required bool isLogin}) {
  return GestureDetector(
    onTap: () {
      context.go(isLogin ? '/register' : '/login');
    },
    child: RichText(
      text: TextSpan(
        text:
            isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
        style: Theme.of(context).textTheme.titleMedium,
        children: [
          TextSpan(
            text: isLogin ? 'Register' : 'Login',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}

Widget buildDetectorForForgotAccount(BuildContext context) {
  return GestureDetector(
    onTap: () {
      context.go('/forgot-account');
    },
    child: const Text(
      'Forgot your account?',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 17,
      ),
    ),
  );
}
