import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/A%20start%20page/register_screen.dart';
import 'package:learn_n/A%20start%20page/start_screen.dart';
import 'package:learn_n/B%20home%20page/home_main_screen.dart';
import 'package:learn_n/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final username = usernameController.text.trim();
        final password = passwordController.text.trim();

        // Query Firestore for the user with the provided username and password
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // User found, use the Firestore database ID
          final userDoc = querySnapshot.docs.first;
          final userId = userDoc.id;

          // Save user ID to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeMainScreen(userId: userId)),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login successful!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid username or password. Please try again.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        print(e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.message}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StartScreen()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
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
                      }
                      return null;
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: buildRetroButton(
                        'Login',
                        const Color.fromARGB(255, 0, 0, 0),
                        loginUser,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, SignupScreen.route());
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have an account? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: 'Register',
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
