import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/utils/general_utils.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/utils/user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
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
    loadUserId(ref);
    loadUserColor(ref);
    Future.delayed(const Duration(seconds: 3), _checkAuthState);
    _updateStreakPoints();
  }

  Future<void> _updateStreakPoints() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data()!;
      final lastActiveDate = (data['lastActiveDate'] as Timestamp?)?.toDate();
      final streakPoints = data['streakPoints'] ?? 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastActiveDate == null ||
          lastActiveDate.isBefore(today.subtract(const Duration(days: 1)))) {
        await userDoc.update({'warning': true});
      } else if (lastActiveDate.isBefore(today)) {
        await userDoc.update({
          'streakPoints': streakPoints + 1,
          'lastActiveDate': today,
          'warning': false,
        });
      }
    } else {
      await userDoc.set({
        'streakPoints': 1,
        'lastActiveDate': DateTime.now(),
        'warning': false,
      });
    }
  }

  Future<void> _checkAuthState() async {
    final userId = ref.read(userIdProvider);

    if (userId != null && kIsWeb) {
      GoRouter.of(context).go('/home');
    } else if (kIsWeb) {
      GoRouter.of(context).go('/web');
    } else if (userId != null) {
      GoRouter.of(context).go('/home');
    } else {
      GoRouter.of(context).go('/intro');
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
