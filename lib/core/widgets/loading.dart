import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/general_utils.dart';
import 'package:learn_n/core/utils/introduction_utils.dart';

class Loading extends StatefulWidget {
  final double size;

  const Loading({super.key, this.size = 100.0});

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> with TickerProviderStateMixin {
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
    )..repeat(reverse: false);

    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _dotTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        loadingText = 'Loading${'.' * ((timer.tick % 3) + 1)}';
      });
    });
  }

  @override
  void dispose() {
    _dotTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          kIsWeb && !isMobileWeb(context)
              ? Image.asset(
                  'assets/logo.png',
                  width: 500,
                  color: Colors.white,
                )
              : Column(
                  children: [
                    buildLogo(Colors.white),
                    buildTitleText('Learn-N', Colors.white),
                  ],
                ),
          const SizedBox(height: 10),
          Text(
            loadingText,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 100,
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Row(
              children: List.generate(10, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: index / 10 <= _progress.value
                          ? Colors.white
                          : Colors.transparent,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
