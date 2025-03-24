import 'package:flutter/material.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/web/web%20widgets/intro_web_page.dart';

class WebMain extends StatelessWidget {
  const WebMain({super.key});

  @override
  Widget build(BuildContext context) {
    double appBarHeight = AppBar().preferredSize.height;
    double screenHeight = MediaQuery.of(context).size.height;
    double adjustedHeight = screenHeight - appBarHeight;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          width: 150,
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              IntroWebPage(height: adjustedHeight),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.black, Colors.grey],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: buildRetroButton('Use Website Application',
                      const Color.fromARGB(0, 255, 255, 255), () {},
                      height: 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
