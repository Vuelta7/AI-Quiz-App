import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/provider/user_provider.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/auth/widgets/auth_textfield.dart';
import 'package:learn_n/features/auth/widgets/text_gesture_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;
  final FocusNode passwordFocusNode = FocusNode();
  int failedAttempts = 0; // Track failed login attempts
  bool showForgotAccount =
      false; // Control visibility of "Forgot your account?" detector

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        final username = usernameController.text.trim().toLowerCase();
        final password = passwordController.text.trim();

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final userId = userDoc.id;
          final userData = userDoc.data();
          final userColorHex = userData['selectedColor'] ?? 'f48fb1';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          ref.read(userIdProvider.notifier).state = userId;

          await UserColorRepository().saveUserColor(userColorHex);
          await loadUserColor(ref);

          setState(() {
            errorMessage = null;
            failedAttempts = 0;
            showForgotAccount = false;
          });
          GoRouter.of(context).go('/home');
        } else {
          failedAttempts++;
          setState(() {
            errorMessage = 'Invalid username or password.';
            if (failedAttempts >= 1) {
              showForgotAccount = true;
            }
          });
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildLogo(Colors.black),
                buildTitleText('Learn-N', Colors.black),
                const SizedBox(height: 20),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      authTextFormField('Username',
                          controller: usernameController, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      }, onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      }),
                      const SizedBox(height: 10),
                      authTextFormField('Password',
                          isPassword: true,
                          controller: passwordController,
                          focusNode: passwordFocusNode, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      }, onFieldSubmitted: (_) {
                        loginUser();
                      }),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                          ),
                        ),
                      buildRetroButton(
                        isLoading ? 'Loading...' : 'Login',
                        Colors.black,
                        isLoading ? null : loginUser,
                      ),
                      if (showForgotAccount) ...[
                        const SizedBox(height: 10),
                        buildDetectorForForgotAccount(context),
                      ],
                      const SizedBox(height: 10),
                      const Divider(thickness: 3),
                      buildGestureDetector(context, isLogin: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
