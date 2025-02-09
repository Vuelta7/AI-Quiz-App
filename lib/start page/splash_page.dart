import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:learn_n/home%20page/home_main.dart';
import 'package:learn_n/start%20page/introduction/liquid_swipe.dart';
import 'package:learn_n/start%20page/start%20page%20utils/start_page_utils.dart';
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
  Color? _selectedColor;

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

    Future.delayed(const Duration(seconds: 3), _checkAuthState);
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? colorHex = prefs.getString('selectedColor');
    setState(() {
      _selectedColor = colorHex != null ? hexToColor(colorHex) : Colors.blue;
    });
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
      backgroundColor: _selectedColor ?? Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildLogo(),
            buildTitleText('Learn-N'),
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
