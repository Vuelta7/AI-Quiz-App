import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/A%20start%20page/drawer_contents.dart';
import 'package:learn_n/A%20start%20page/sign_up_screen.dart';
import 'package:learn_n/B%20home%20page/home_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late Timer _dotTimer;
  String loadingText = 'Loading';

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Define the progress animation
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Start the animation
    _controller.forward();

    // Timer to update loading text
    _dotTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        loadingText = 'Loading${'.' * ((timer.tick % 3) + 1)}';
      });
    });

    // Navigate after animation finishes
    Future.delayed(const Duration(seconds: 3), _checkAuthState);
  }

  Future<void> _checkAuthState() async {
    if (!mounted) return;

    // Add debugging information
    print("Checking Firebase Authentication State...");

    User? user = FirebaseAuth.instance.currentUser;

    // Debugging: Log the user state
    print("Current User: $user");

    if (user != null) {
      // User is logged in, navigate to HomeMainWidget
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeMainScreen()),
      );
    } else {
      // User is not logged in, navigate to SignupScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );
    }
  }

  @override
  void dispose() {
    _dotTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo_icon.png',
              width: 200,
              height: 200,
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
            const SizedBox(height: 300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loadingText,
                    style: const TextStyle(fontFamily: 'PressStart2P'),
                  ),
                  Container(
                    width: 260,
                    height: 26,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: List.generate(10, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: index / 10 <= _progress.value
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late bool _isDoNotDisturb = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[600],
              border: const Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 4.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo_icon.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn-N',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PressStart2P"),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.do_not_disturb,
              color: Colors.black,
            ),
            title: const Text(
              'Do Not Disturb',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Switch(
              activeColor: Colors.black,
              value: _isDoNotDisturb,
              onChanged: (bool value) {
                setState(() {
                  _isDoNotDisturb = value;
                });
              },
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.feedback,
              color: Colors.black,
            ),
            title: const Text(
              'Feedback or Question',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrawerContent(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.black),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrawerContent(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.black),
            title: const Text(
              'About Us',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DrawerContent()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout successful!'),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupScreen(),
                ),
              );

              print('User logged out');
            },
          ),
        ],
      ),
    );
  }
}
