import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';

class StorePage extends StatelessWidget {
  final String userId;
  final Color color;
  const StorePage({super.key, required this.userId, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getShade(color, 300),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
