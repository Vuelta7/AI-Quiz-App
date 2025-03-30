import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebPCView extends StatelessWidget {
  const WebPCView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(width: 2),
                      ),
                      child: SizedBox(
                        width: 1400,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Learn-N: Your Study Tool',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PressStart2P',
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Learn-N is created to assist students in preparing for tests, '
                                'quizzes, and other academic assignments. Students may learn on the road with '
                                'ease thanks to its mobility and simple access, which were designed especially '
                                'for mobile devices. Because of its emphasis on simplicity, the app is '
                                'straightforward to use and navigate, enabling students to focus on their '
                                'studies without interruptions.',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Verdana',
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  3,
                                  (index) => _buildHoverableImage(
                                    'assets/${index + 1}.webp',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 70),
                              const Text(
                                'The software is a flexible tool for studying and remembering crucial information '
                                'because it lets users make and modify flashcards. The app uses the combination of '
                                'active recall and spaced repetition, which makes remembering your flashcards easily. '
                                'In order to facilitate effective sorting and simple material retrieval, students can '
                                'arrange their flashcards into folders. Learn-N helps students stay organized and '
                                'improve their educational experience with its practical design and customizable features.',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Verdana',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: _buildDownloadBox(),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          _buildNavbar(),
        ],
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 5,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) {},
        onExit: (_) {},
        child: Center(
          child: SizedBox(
            width: 1200,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Image.asset(
                'assets/logo.png',
                height: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoverableImage(String imagePath) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: HoverableWidget(
        builder: (isHovering) {
          return Container(
            width: 300,
            height: 650,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isHovering ? Colors.black : Colors.grey,
                width: 1,
              ),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadBox() {
    return HoverableWidget(
      builder: (isHovering) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                isHovering ? const Color(0xFF4E4E4E) : Colors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          transform: isHovering
              ? Matrix4.diagonal3Values(1.025, 1.025, 1)
              : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download Learn-N',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Trebuchet MS',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'To download Learn-N app, click the download button below.',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Verdana',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 75),
              HoverableWidget(
                builder: (isButtonHovering) {
                  return InkWell(
                    onTap: () => _launchDownload(),
                    child: Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isButtonHovering
                            ? Colors.white
                            : Colors.transparent,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'Start Download',
                          style: TextStyle(
                            color:
                                isButtonHovering ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchDownload() async {
    const fileId = "1XH6Al1WzlPffTdHCyGd039i7PEuF5Fkx";
    final Uri downloadLink =
        Uri.parse("https://drive.google.com/uc?export=download&id=$fileId");

    if (await canLaunchUrl(downloadLink)) {
      await launchUrl(downloadLink, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $downloadLink';
    }
  }
}

class HoverableWidget extends StatefulWidget {
  final Widget Function(bool isHovering) builder;

  const HoverableWidget({super.key, required this.builder});

  @override
  _HoverableWidgetState createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<HoverableWidget> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: widget.builder(isHovering),
    );
  }
}
