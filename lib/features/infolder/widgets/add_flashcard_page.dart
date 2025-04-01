import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/infolder/widgets/auto_quiz.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class AddFlashCardPage extends StatefulWidget {
  final String folderId;
  final Color color;

  const AddFlashCardPage(
      {super.key, required this.folderId, required this.color});

  @override
  State<AddFlashCardPage> createState() => _AddFlashCardPageState();
}

class _AddFlashCardPageState extends State<AddFlashCardPage> {
  final answerController = TextEditingController();
  final questionController = TextEditingController();
  bool _isLoading = false;
  List<TextEditingController> questionControllers = [];
  List<TextEditingController> answerControllers = [];
  List<String> flashCardIds = [];

  @override
  void dispose() {
    answerController.dispose();
    questionController.dispose();
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchExistingFlashcards();
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
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> fetchExistingFlashcards() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .collection("questions")
          .get();

      setState(() {
        for (var doc in snapshot.docs) {
          flashCardIds.add(doc.id);
          questionControllers.add(TextEditingController(text: doc['question']));
          answerControllers.add(TextEditingController(text: doc['answer']));
        }
      });
    } catch (e) {
      print("Error fetching flashcards: $e");
    }
  }

  Future<void> updateFlashCardInDb(
      String flashCardId, String question, String answer) async {
    try {
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .collection("questions")
          .doc(flashCardId)
          .update({
        "question": question.trim(),
        "answer": answer.trim(),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteFlashCardFromDb(String flashCardId) async {
    try {
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .collection("questions")
          .doc(flashCardId)
          .delete();
      setState(() {
        int index = flashCardIds.indexOf(flashCardId);
        flashCardIds.removeAt(index);
        questionControllers.removeAt(index);
        answerControllers.removeAt(index);
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
        backgroundColor: widget.color,
        title: const Text(
          'Flashcard Manager',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: widget.color,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                buildRetroButton(
                  'Add Flashcard',
                  icon: Icons.add_box,
                  height: 60,
                  getShade(widget.color, 300),
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Add Flashcard'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: questionController,
                                decoration: const InputDecoration(
                                  hintText: 'Question or Definition',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: answerController,
                                decoration: const InputDecoration(
                                  hintText: 'Answer',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (questionController.text.trim().isEmpty ||
                                    answerController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please enter both question and answer.'),
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
                                  Navigator.of(context).pop();
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
                              child: const Text('submit'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                buildRetroButton(
                  'Quiz Generator',
                  height: 60,
                  icon: Icons.quiz,
                  getShade(widget.color, 300),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AutoQuizPage(
                          folderId: widget.folderId,
                          color: widget.color,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Existing Flashcards:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'PressStart2P',
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("folders")
                      .doc(widget.folderId)
                      .collection("questions")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loading();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/makequiz.json',
                              ),
                              const Text(
                                'No Flashcards here!\nCreate one by clicking the\n"Add Flashcard"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    var flashcards = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: flashcards.length,
                      itemBuilder: (context, index) {
                        var flashcard = flashcards[index];
                        var questionController =
                            TextEditingController(text: flashcard['question']);
                        var answerController =
                            TextEditingController(text: flashcard['answer']);
                        return Card(
                          color: getShade(widget.color, 300),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: questionController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Question',
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: answerController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Answer',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.save,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        updateFlashCardInDb(
                                          flashcard.id,
                                          questionController.text,
                                          answerController.text,
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Flashcard updated!')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        deleteFlashCardFromDb(flashcard.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Flashcard deleted!')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (_isLoading) const Loading(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
