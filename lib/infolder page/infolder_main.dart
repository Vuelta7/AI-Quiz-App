import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              size: 30, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
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
                      color: Colors.black,
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          FlashcardsPage(
            folderId: widget.folderId,
            isEditing: _isEditing,
          ),
          LeaderboardPage(folderId: widget.folderId),
        ],
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
                    closedColor: Colors.black,
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
                    closedColor: Colors.black,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_rounded, size: 50),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard, size: 50),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
