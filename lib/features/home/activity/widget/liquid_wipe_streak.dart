import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:lottie/lottie.dart';

class LiquidSwipeStreak extends StatefulWidget {
  const LiquidSwipeStreak({super.key});

  @override
  State<LiquidSwipeStreak> createState() => _LiquidSwipeStreakState();
}

class _LiquidSwipeStreakState extends State<LiquidSwipeStreak> {
  int page = 0;
  late LiquidController liquidController;

  final pages = [
    StreakTutorialPage(
      description:
          "This is your default streak pet. Keep your streak for 10 days to upgrade to Streak Pet 2!",
      lottieAsset: 'assets/lottie/streakpet3.json',
      daysRequired: "0-9 Days",
      color: Colors.purple[300]!,
    ),
    const StreakTutorialPage(
      description: "Keep your streak for 30 days to upgrade to Streak Pet 1!",
      lottieAsset: 'assets/lottie/streakpet2.json',
      daysRequired: "10-29 Days",
      color: Colors.teal,
    ),
    const StreakTutorialPage(
      description: "Keep your streak alive to maintain this pet!",
      lottieAsset: 'assets/lottie/streakpet1.json',
      daysRequired: "30+ Days",
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
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
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.cancel_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  void pageChangeCallback(int activePageIndex) {
    setState(() {
      page = activePageIndex;
    });
  }
}

class StreakTutorialPage extends StatelessWidget {
  final String description;
  final String lottieAsset;
  final String? daysRequired;
  final Color color;

  const StreakTutorialPage({
    super.key,
    required this.description,
    required this.lottieAsset,
    required this.color,
    this.daysRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(children: [
              Lottie.asset(
                'assets/lottie/effectbg.json',
                width: 300,
                height: 300,
              ),
              Lottie.asset(
                lottieAsset,
                width: 300,
                height: 300,
              ),
            ]),
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'PressStart2P',
            ),
          ),
          if (daysRequired != null)
            Text(
              "Days Required: $daysRequired",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'PressStart2P',
              ),
            ),
        ],
      ),
    );
  }
}
