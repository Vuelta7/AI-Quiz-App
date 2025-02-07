import 'package:flutter/material.dart';
import 'package:learn_n/practice/test.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      home: ChatScreen(),
    );
  }
}
