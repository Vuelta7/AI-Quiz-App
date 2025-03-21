import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learn_n/features/introduction/master_intro_page.dart';
import 'package:learn_n/features/introduction/start_page.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class LiquidSwipeIntro extends StatefulWidget {
  const LiquidSwipeIntro({super.key});

  @override
  State<LiquidSwipeIntro> createState() => _LiquidSwipeIntroState();
}

class _LiquidSwipeIntroState extends State<LiquidSwipeIntro> {
  int page = 0;
  late LiquidController liquidController;
  late UpdateType updateType;

  final pages = [
    const WelcomePage(),
    const IntroPage(),
    const StartPage(),
  ];

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
  }

  Widget _buildDot(int index) {
    double selectedNess = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page) - index).abs(),
      ),
    );

    double zoom = 1.0 + (1.0) * selectedNess;

    return SizedBox(
      width: 25,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: SizedBox(
            height: 8.0 * zoom,
            width: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages,
            positionSlideIcon: 0.8,
            slideIconWidget: page == pages.length - 1
                ? null
                : const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
            onPageChangeCallback: pageChangeCallback,
            waveType: WaveType.liquidReveal,
            liquidController: liquidController,
            fullTransitionValue: 500,
            enableSideReveal: false,
            preferDragFromRevealedArea: true,
            ignoreUserGestureWhileAnimating: true,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Expanded(
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, _buildDot),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: page == pages.length - 1
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () {
                        liquidController.animateToPage(
                            page: pages.length - 1, duration: 700);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PressStart2P',
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void pageChangeCallback(int activePageIndex) {
    setState(() {
      page = activePageIndex;
    });
  }
}
