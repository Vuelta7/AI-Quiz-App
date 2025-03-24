import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';
import 'package:learn_n/features/home/home_main.dart';
import 'package:learn_n/features/introduction/liquid_swipe.dart';
import 'package:learn_n/features/web/web_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    _dotTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        loadingText = 'Loading${'.' * ((timer.tick % 3) + 1)}';
      });
    });

    Future.delayed(
        const Duration(seconds: 3), kIsWeb ? _goWeb : _checkAuthState);
  }

  void _goWeb() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WebMain()),
    );
  }

  bool isMobileWeb(BuildContext context) {
    return kIsWeb && MediaQuery.of(context).size.width < 800;
  }

  Future<void> _checkAuthState() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeMain(userId: userId)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LiquidSwipeIntro()),
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
            kIsWeb && !isMobileWeb(context)
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 500,
                    ),
                  )
                : Column(
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                        child: Column(
                          children: [
                            buildLogo(),
                            buildTitleText('Learn-N'),
                          ],
                        ),
                      )
                    ],
                  ),
            const SizedBox(height: 300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loadingText,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      color: Colors.black,
                    ),
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
