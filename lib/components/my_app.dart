import 'package:flutter/material.dart';
import 'package:learn_n/providers/theme_provider.dart';
import 'package:learn_n/start%20page/splash_page.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      home: const SplashScreen(),
      theme: themeProvider.themeData,
    );
  }
}
