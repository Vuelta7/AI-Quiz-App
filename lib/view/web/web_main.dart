import 'package:flutter/material.dart';
import 'package:learn_n/core/widgets/retro_button.dart';

class WebMain extends StatelessWidget {
  const WebMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 150,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const Text(
              'The Fastest Way To Learn',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.cyan, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: buildRetroButton(
                    'Download App', Colors.transparent, () {},
                    height: 50),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.purple, Colors.cyan],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/screenshot.webp',
                width: double.infinity,
                height: 600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
