import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/features/home/home_main.dart';
import 'package:learn_n/features/infolder/page/flashcards_page.dart';
import 'package:learn_n/features/infolder/page/leaderboards_page.dart';
import 'package:learn_n/features/infolder/page/play_page.dart';
import 'package:learn_n/features/infolder/widgets/edit_library_button.dart';

class InFolderMain extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color color;
  final bool isImported;

  const InFolderMain({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.color,
    this.isImported = true,
  });

  @override
  State<InFolderMain> createState() => _InFolderMainState();
}

class _InFolderMainState extends State<InFolderMain>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _wiggleController;
  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;
  late AnimationController _hideFabAnimationController;
  late FlashcardsPage _flashcardsPage;
  late LeaderboardPage _leaderboardPage;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hideFabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _borderRadiusAnimationController.forward(),
    );

    _flashcardsPage = FlashcardsPage(
      folderId: widget.folderId,
      color: widget.color,
    );
    _leaderboardPage = LeaderboardPage(folderId: widget.folderId);
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    _hideFabAnimationController.dispose();
    super.dispose();
  }

  Future<List<Map<String, String>>> getQuestions() async {
    final questionsSnapshot = await FirebaseFirestore.instance
        .collection('folders')
        .doc(widget.folderId)
        .collection('questions')
        .get();

    final questions = questionsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id,
        "question": data['question']?.toString() ?? '',
        "answer": data['answer']?.toString() ?? '',
      };
    }).toList();

    return questions;
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.forward();
          _hideFabAnimationController.reverse();
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _hideFabAnimationController.reverse();
          break;
        case ScrollDirection.idle:
          _hideBottomBarAnimationController.reverse();
          _hideFabAnimationController.forward();
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            widget.folderName,
            style: TextStyle(
              color: getColorForTextAndIcon(widget.color),
              fontFamily: 'PressStart2P',
              fontSize: 16,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  color: getShade(widget.color, 500),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 30,
              color: getColorForTextAndIcon(widget.color),
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  color: getShade(widget.color, 500),
                  blurRadius: 0,
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeMain(),
                ),
              );
            },
          ),
          backgroundColor: widget.color,
          actions: [
            EditLibraryButton(
              color: widget.color,
              folderId: widget.folderId,
            ),
          ],
        ),
        backgroundColor: getShade(widget.color, 700),
        body: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _flashcardsPage,
              _leaderboardPage,
            ],
          ),
        ),
        floatingActionButton: _selectedIndex == 0
            ? FadeTransition(
                opacity: _hideFabAnimationController,
                child: FloatingActionButton(
                  onPressed: () async {
                    final questions = await getQuestions();
                    if (questions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No questions available in this folder.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              color: widget.color,
                            ),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayPage(
                            folderName: widget.folderName,
                            folderId: widget.folderId,
                            color: widget.color,
                            questions: questions,
                            isImported: widget.isImported,
                          ),
                        ),
                      );
                    }
                  },
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: AnimatedBuilder(
                    animation: _wiggleController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: 0.2 * _wiggleController.value,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 45,
                          color: getShade(widget.color, 800),
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              color: getShade(widget.color, 500),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: 2,
          tabBuilder: (int index, bool isActive) {
            const color = Colors.white;
            final showLabel = isActive || _selectedIndex == index;

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  index == 0 ? Icons.question_answer_rounded : Icons.people,
                  size: 45,
                  color: color,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      color: getShade(widget.color, 500),
                      blurRadius: 0,
                    ),
                  ],
                ),
                if (showLabel)
                  Text(
                    index == 0 ? 'Flashcards' : 'Learners',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontFamily: 'PressStart2P',
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          color: getShade(widget.color, 500),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  )
              ],
            );
          },
          height: 70,
          backgroundColor: getShade(widget.color, 800),
          activeIndex: _selectedIndex,
          splashColor: widget.color,
          notchAndCornersAnimation: borderRadiusAnimation,
          splashSpeedInMilliseconds: 100,
          notchSmoothness: NotchSmoothness.defaultEdge,
          gapLocation: GapLocation.center,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (index) => setState(() => _selectedIndex = index),
          hideAnimationController: _hideBottomBarAnimationController,
        ),
      ),
    );
  }
}
