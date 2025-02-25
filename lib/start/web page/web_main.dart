import 'package:flutter/material.dart';

class WebMain extends StatelessWidget {
  const WebMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 200,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
    );
  }
}
