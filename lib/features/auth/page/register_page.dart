import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/auth/widgets/auth_textfield.dart';
import 'package:learn_n/features/auth/widgets/text_gesture_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      );

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController petnameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    petnameController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        final username = usernameController.text.trim().toLowerCase();
        final password = passwordController.text.trim();
        final petname = petnameController.text.trim();

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() => errorMessage =
              'Username already exists. Please choose another one.');
          return;
        }

        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        final firebaseUser = userCredential.user;

        const defaultColorHex = 'f48fb1';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser!.uid)
            .set({
          'username': username,
          'password': password,
          'petName': petname,
          'currencypoints': 0,
          'hints': 0,
          'selectedColor': defaultColorHex,
          'streakPoints': 0,
          'lastActiveDate': Timestamp.now(),
          'warning': false,
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', firebaseUser.uid);
        ref.read(userIdProvider.notifier).state = firebaseUser.uid;

        await UserColorRepository().saveUserColor(defaultColorHex);
        ref.read(userColorProvider.notifier).state = const Color(0xFFF48FB1);

        setState(() => errorMessage = null);
        GoRouter.of(context).go('/home');
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
                  'Register',
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
                      authTextFormField('Pet name',
                          controller: petnameController, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Petname is required';
                        }
                        return null;
                      }, onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(usernameFocusNode);
                      }),
                      const SizedBox(height: 10),
                      authTextFormField('Username',
                          controller: usernameController,
                          focusNode: usernameFocusNode, validator: (value) {
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
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      }, onFieldSubmitted: (_) {
                        registerUser();
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
                        isLoading ? 'Loading...' : 'Register',
                        Colors.black,
                        isLoading ? null : registerUser,
                      ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 3),
                      buildGestureDetector(context, isLogin: false),
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
