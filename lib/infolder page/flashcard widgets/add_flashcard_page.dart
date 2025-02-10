import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/components/loading.dart';
import 'package:learn_n/start%20page/start%20page%20utils/start_page_button.dart';
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
      backgroundColor: widget.color,
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
                  buildRetroButton(
                    'SUBMIT',
                    Colors.black,
                    _isLoading
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
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Loading(),
        ],
      ),
    );
  }
}
