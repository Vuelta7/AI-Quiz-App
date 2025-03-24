import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/home/home_main.dart';
import 'package:url_launcher/url_launcher.dart';

class WebMain extends StatefulWidget {
  final String userId;
  const WebMain({super.key, required this.userId});

  @override
  State<WebMain> createState() => _WebMainState();
}

class _WebMainState extends State<WebMain> {
  bool showCursor = true;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        showCursor = !showCursor;
      });
    });
  }

  void downloadMobileApp() async {
    final Uri url = Uri.parse(
        'https://drive.google.com/uc?export=download&id=1XH6Al1WzlPffTdHCyGd039i7PEuF5Fkx');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void navigateToStartPage() {
    if (widget.userId != '') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return HomeMain(
            userId: widget.userId,
          );
        }),
      );
    } else {
      Navigator.pushNamed(context, '/startPage');
    }
  }

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
            child: SizedBox(
          height: adjustedHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'The Best Way To Practice Quiz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'PressStart2P',
                ),
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
                  child: SizedBox(
                    width: 600,
                    child: buildRetroButton(
                        'Download Mobile Application',
                        const Color.fromARGB(0, 255, 255, 255),
                        downloadMobileApp,
                        height: 70),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                  child: Column(
                    children: [
                      Material(
                        borderOnForeground: true,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          width: 600,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 82, 82, 82),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              width: 3,
                              color: Colors.white,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '_',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Divider(
                                thickness: 3,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Best App to Practice Quiz, and with automatic quiz generator for learners, user friendly experience and customizable interface',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 600,
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: TextField(
                            enabled: false,
                            controller: TextEditingController(
                                text: showCursor ? "Learn-N|" : "Learn-N"),
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type Answer',
                              hintStyle: const TextStyle(
                                fontFamily: 'PressStart2P',
                                color: Colors.white,
                              ),
                              labelStyle: const TextStyle(
                                fontFamily: 'PressStart2P',
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: Colors.grey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(
                        width: 600,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 45,
                              color: Colors.white,
                            ),
                            Icon(
                              Icons.lightbulb,
                              size: 30,
                              color: Colors.white,
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 45,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                          child: SizedBox(
                            width: 600,
                            child: buildRetroButton(
                                'Use Web App',
                                const Color.fromARGB(0, 255, 255, 255),
                                navigateToStartPage,
                                height: 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
