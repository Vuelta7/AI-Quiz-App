import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/home_main_screen.dart';
import 'package:learn_n/C%20folder%20page/flashcard_model_widget.dart';
import 'package:learn_n/C%20folder%20page/question_multiple_option_model_widget.dart';
import 'package:learn_n/C%20folder%20page/question_typing_mode_model_widget.dart';
import 'package:uuid/uuid.dart';

class InsideFolderMain extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color headerColor;

  const InsideFolderMain({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.headerColor,
  });

  @override
  State<InsideFolderMain> createState() => _InsideFolderMainState();
}

class _InsideFolderMainState extends State<InsideFolderMain> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeMainScreen(),
        ),
      );
    } else if (index == 1) {
      try {
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

        if (questions.isNotEmpty) {
          _showChooseModeDialog(questions);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions available to play.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFlashCardScreen(folderId: widget.folderId),
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showChooseModeDialog(List<Map<String, String>> questions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose a Quiz Mode',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionTypingModeModelWidget(
                          folderName: widget.folderName,
                          folderId: widget.folderId,
                          headerColor: widget.headerColor,
                          questions: questions,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    fixedSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Typing Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuestionMultipleOptionModeModelWidget(
                          folderName: widget.folderName,
                          folderId: widget.folderId,
                          headerColor: widget.headerColor,
                          questions: questions,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    fixedSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Multiple Option Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                    fixedSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: InsideFolderBody(folderId: widget.folderId),
          ),
        ],
      ),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('folders')
            .doc(widget.folderId)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshot) {
          final hasFlashcards =
              snapshot.hasData && snapshot.data!.docs.isNotEmpty;

          return BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 1 && !hasFlashcards) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No flashcards to play.')),
                );
                return;
              }
              _onItemTapped(index);
            },
            selectedItemColor: Colors.black,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded, size: 50),
                label: 'Back to Folders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_fill_rounded, size: 50),
                label: 'Play',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_rounded, size: 50),
                label: 'Add Flashcard',
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddFlashcardButtonWidget extends StatelessWidget {
  final String folderId;
  const AddFlashcardButtonWidget({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.add_box_rounded,
        size: 40,
      ),
      color: Colors.black,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddFlashCardScreen(
              folderId: folderId,
            );
          },
        );
      },
    );
  }
}

class AddFlashCardScreen extends StatefulWidget {
  final String folderId;

  const AddFlashCardScreen({super.key, required this.folderId});

  @override
  State<AddFlashCardScreen> createState() => _AddFlashCardScreenState();
}

class _AddFlashCardScreenState extends State<AddFlashCardScreen> {
  final answerController = TextEditingController();
  final questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    answerController.dispose();
    questionController.dispose();
    super.dispose();
  }

  Future<void> uploadFlashCardToDb() async {
    try {
      final id = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .collection("questions")
          .doc(id)
          .set({
        "answer": answerController.text.trim(),
        "question": questionController.text.trim(),
        "creator": FirebaseAuth.instance.currentUser!.uid,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Flashcard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      hintText: 'Answer',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: questionController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      hintText: 'Question or Definition',
                    ),
                    maxLines: 14,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (answerController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a question.'),
                                ),
                              );
                              return;
                            }
                            if (questionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter an answer.'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await uploadFlashCardToDb();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Flashcard added successfully!'),
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class InsideFolderBody extends StatelessWidget {
  final String folderId;

  const InsideFolderBody({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .collection('questions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(
              child: Text(
                'No Flashcards here 🗂️\nCreate one by clicking the Add Flashcards.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final questionDoc = snapshot.data!.docs[index];
            final questionData = questionDoc.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FlashCardModel(
                question: questionData['question'],
                answer: questionData['answer'],
                questionId: questionDoc.id,
                folderId: folderId,
              ),
            );
          },
        );
      },
    );
  }
}
