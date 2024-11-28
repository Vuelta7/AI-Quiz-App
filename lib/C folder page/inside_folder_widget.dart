import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/home_main_screen.dart';
import 'package:learn_n/C%20folder%20page/flashcard_model_widget.dart';
import 'package:learn_n/C%20folder%20page/question_model_widget.dart';
import 'package:uuid/uuid.dart';

// can u please fix my functions on bottomnavbar
class InsideFolderMain extends StatefulWidget {
  final String folderId;
  final String folderName;

  const InsideFolderMain({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<InsideFolderMain> createState() => _InsideFolderMainState();
}

class _InsideFolderMainState extends State<InsideFolderMain> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 0) {
      // Navigate back to the Home Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeMainScreen(),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFlashCardScreen(folderId: widget.folderId),
        ),
      );
    } else if (index == 2) {
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionModelWidget(
              folderName: widget.folderName,
              folderId: widget.folderId,
              questions: List<Map<String, String>>.from(questions),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: InsideFolderBody(folderId: widget.folderId),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded, size: 50),
            label: 'Back to Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded, size: 50),
            label: 'Add Flashcard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_rounded, size: 50),
            label: 'Play',
          ),
        ],
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
  final questionController = TextEditingController();
  final answerController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
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
        "question": questionController.text.trim(),
        "answer": answerController.text.trim(),
        "creator": FirebaseAuth.instance.currentUser!.uid,
      });
    } catch (e) {
      print(e);
      throw e;
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
            fontFamily: 'PressStart2P',
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      hintText: 'Question or Definition',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      hintText: 'Answer',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (questionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a question.'),
                                ),
                              );
                              return;
                            }
                            if (answerController.text.trim().isEmpty) {
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
          return const Center(
            child: Text('No questions found :<'),
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
