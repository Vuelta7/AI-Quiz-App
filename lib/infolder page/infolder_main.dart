import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_n/infolder%20page/flashcard%20widgets/add_flashcard_page.dart';
import 'package:learn_n/infolder%20page/infolder%20page/flashcards_page.dart';
import 'package:learn_n/infolder%20page/infolder%20page/leaderboards_page.dart';
import 'package:learn_n/infolder%20page/play%20page/play_page.dart';

class InFolderMain extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color headerColor;
  final bool isImported;

  const InFolderMain({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.headerColor,
    this.isImported = true,
  });

  @override
  State<InFolderMain> createState() => _InFolderMainState();
}

class _InFolderMainState extends State<InFolderMain>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isEditing = false;
  late AnimationController _wiggleController;
  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

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

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _wiggleController.repeat(reverse: true);
      } else {
        _wiggleController.stop();
      }
    });
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

  Future<bool> hasQuestions() async {
    final questions = await getQuestions();
    return questions.isNotEmpty;
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white; // Manually specified color
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: TextStyle(
            color: textColor,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 30, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: widget.headerColor, // Manually specified color
        actions: [
          if (_selectedIndex == 0 && !widget.isImported)
            FutureBuilder<bool>(
              future: hasQuestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasData && snapshot.data!) {
                  return IconButton(
                    icon: Icon(
                      _isEditing ? Icons.play_circle_fill_rounded : Icons.edit,
                      size: 40,
                      color: textColor,
                    ),
                    onPressed: _toggleEditMode,
                  );
                } else {
                  return Container();
                }
              },
            ),
        ],
      ),
      backgroundColor:
          widget.headerColor.withOpacity(0.7), // Manually specified color
      body: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            FlashcardsPage(
              folderId: widget.folderId,
              isEditing: _isEditing,
            ),
            LeaderboardPage(folderId: widget.folderId),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FutureBuilder<bool>(
              future: hasQuestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!) {
                  return OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (BuildContext context, VoidCallback _) {
                      return AddFlashCardPage(folderId: widget.folderId);
                    },
                    closedElevation: 6.0,
                    closedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(28.0),
                      ),
                    ),
                    closedColor: widget.headerColor
                        .withOpacity(0.9), // Manually specified color
                    closedBuilder:
                        (BuildContext context, VoidCallback openContainer) {
                      return SizedBox(
                        height: 56.0,
                        width: 56.0,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _wiggleController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: 0.2 * _wiggleController.value,
                                child: const Icon(
                                  Icons.add,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (BuildContext context, VoidCallback _) {
                      if (_isEditing) {
                        return AddFlashCardPage(folderId: widget.folderId);
                      } else {
                        return FutureBuilder<List<Map<String, String>>>(
                          future: getQuestions(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              ));
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Center(
                                  child: Text('Error loading questions'));
                            } else {
                              return PlayPage(
                                folderName: widget.folderName,
                                folderId: widget.folderId,
                                headerColor: widget.headerColor,
                                questions: snapshot.data!,
                              );
                            }
                          },
                        );
                      }
                    },
                    closedElevation: 6.0,
                    closedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(28.0),
                      ),
                    ),
                    closedColor: widget.headerColor
                        .withOpacity(0.9), // Manually specified color
                    closedBuilder:
                        (BuildContext context, VoidCallback openContainer) {
                      return SizedBox(
                        height: 56.0,
                        width: 56.0,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _wiggleController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: 0.2 * _wiggleController.value,
                                child: Icon(
                                  _isEditing
                                      ? Icons.add
                                      : Icons.play_arrow_rounded,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 2,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.white : Colors.black;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                index == 0 ? Icons.question_answer_rounded : Icons.leaderboard,
                size: 45,
                color: color,
              ),
              Text(
                index == 0 ? 'Questions' : 'Leaderboard',
                style: TextStyle(color: color, fontSize: 12),
              )
            ],
          );
        },
        height: 70,
        backgroundColor: widget.headerColor, // Manually specified color
        activeIndex: _selectedIndex,
        splashColor: widget.headerColor,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 100,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _selectedIndex = index),
        hideAnimationController: _hideBottomBarAnimationController,
      ),
    );
  }
}
