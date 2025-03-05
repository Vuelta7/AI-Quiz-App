import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_n/core/widgets/retro_button.dart';

class IntroWebPage extends StatefulWidget {
  final double height;
  const IntroWebPage({super.key, required this.height});

  @override
  State<IntroWebPage> createState() => _IntroWebPageState();
}

class _IntroWebPageState extends State<IntroWebPage> {
  bool showCursor = true;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        showCursor = !showCursor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'The Best Way To Practice Quiz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.white,
              fontFamily: 'PressStart2P',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.cyan, Colors.pink],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: buildRetroButton('Use Android Application',
                  const Color.fromARGB(0, 255, 255, 255), () {},
                  height: 70),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pink, Colors.cyan],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
              child: Column(
                children: [
                  Material(
                    borderOnForeground: true,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          width: 3,
                          color: Colors.white,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '_',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Divider(
                            thickness: 3,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Best App to Practice Quiz, and with automatic quiz generator for learners, user friendly experience and customizable interface',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(
                          text: showCursor ? "Learn-N|" : "Learn-N"),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type Answer',
                        hintStyle: const TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.white,
                        ),
                        labelStyle: const TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: Colors.cyan,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 45,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.lightbulb,
                        size: 30,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 45,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
