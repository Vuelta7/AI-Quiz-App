import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/A%20start%20page/login_screen.dart';
import 'package:learn_n/B%20home%20page/home_main_screen.dart';
import 'package:learn_n/util.dart';

class SignupScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      );

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        // Sign in anonymously
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        final uid = userCredential.user!.uid;

        // Store username, password, and points in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
          'points': 0,
        });

        setState(() => errorMessage = null);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeMainScreen()));
      } on FirebaseAuthException catch (e) {
        setState(() => errorMessage = e.message);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
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
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    buildRetroTextField('Username',
                        controller: usernameController, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    }),
                    const SizedBox(height: 10),
                    buildRetroTextField('Password',
                        isPassword: true,
                        controller: passwordController, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    }),
                    const SizedBox(height: 20),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    SizedBox(
                      width: 170,
                      child: buildRetroButton(
                        isLoading ? 'Loading...' : 'Register',
                        const Color.fromARGB(255, 0, 0, 0),
                        isLoading ? null : registerUser,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, LoginScreen.route());
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
