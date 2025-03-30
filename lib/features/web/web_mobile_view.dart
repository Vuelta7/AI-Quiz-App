import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:url_launcher/url_launcher.dart';

class WebMobileview extends ConsumerStatefulWidget {
  const WebMobileview({super.key});

  @override
  ConsumerState<WebMobileview> createState() => _WebMainState();
}

class _WebMainState extends ConsumerState<WebMobileview> {
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
    final userId = ref.read(userIdProvider);
    if (userId != '') {
      GoRouter.of(context).go('/home');
    } else {
      GoRouter.of(context).go('/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
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
          height: 1500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 200),
              const Text(
                'The Best Way\nTo Practice Quiz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: 'PressStart2P',
                ),
              ),
              const SizedBox(height: 200),
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
                              fillColor: const Color.fromARGB(255, 82, 82, 82),
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
