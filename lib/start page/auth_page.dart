import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/home%20page/home_main.dart';
import 'package:learn_n/utils/auth_textfield.dart';
import 'package:learn_n/utils/color_utils.dart';
import 'package:learn_n/utils/retro_button.dart';
import 'package:learn_n/utils/start_page_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({super.key, required this.isLogin});

  static route({required bool isLogin}) => MaterialPageRoute(
        builder: (context) => AuthScreen(isLogin: isLogin),
      );

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isLoading = false;
  final FocusNode passwordFocusNode = FocusNode();
  Color selectedColor = Colors.blue;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorString =
        prefs.getString('selectedColor') ?? rgbToHex(Colors.blue);
    setState(() {
      selectedColor = hexToColor(colorString);
    });
  }

  Future<void> authenticateUser() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        if (widget.isLogin) {
          await loginUser();
        } else {
          await registerUser();
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> registerUser() async {
    final username = usernameController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    // Check if the username already exists
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() =>
          errorMessage = 'Username already exists. Please choose another one.');
      return;
    }

    // Sign in anonymously to get a Firebase Auth user
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final firebaseUser = userCredential.user;

    // Create a new user in Firestore with the Firebase user ID
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .set({
      'username': username,
      'password': password,
      'currencypoints': 0,
      'rankpoints': 0,
      'hints': 0,
      'heatmap': {},
      'selectedColor': rgbToHex(Colors.blue),
    });

    // Save user ID to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', firebaseUser.uid);

    setState(() => errorMessage = null);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeMain(
          userId: firebaseUser.uid,
        ), // Default color
      ),
    );
  }

  Future<void> loginUser() async {
    final username = usernameController.text.trim().toLowerCase();
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
      final userData = userDoc.data();

      // Save user ID and selected color to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('selectedColor', userData['selectedColor']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeMain(
                  userId: userId,
                )),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColor,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildLogo(),
                buildTitleText('Learn-N'),
                const SizedBox(height: 20),
                Text(
                  widget.isLogin ? 'Login' : 'Register',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AuthTextFormField('Username',
                          controller: usernameController, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      }, onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      }),
                      const SizedBox(height: 10),
                      AuthTextFormField('Password',
                          isPassword: true,
                          controller: passwordController,
                          focusNode: passwordFocusNode, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        } else if (!widget.isLogin && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      }, onFieldSubmitted: (_) {
                        authenticateUser();
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
                        isLoading
                            ? 'Loading...'
                            : widget.isLogin
                                ? 'Login'
                                : 'Register',
                        getShade(selectedColor, 300),
                        isLoading ? null : authenticateUser,
                      ),
                      const SizedBox(height: 20),
                      buildGestureDetector(context, isLogin: widget.isLogin),
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
