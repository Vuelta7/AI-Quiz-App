import 'package:flutter/material.dart';
import 'package:learn_n/start%20page/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      home: SplashScreen(),
    );
  }
}
