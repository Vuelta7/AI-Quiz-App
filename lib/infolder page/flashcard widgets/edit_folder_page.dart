import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/utils/retro_button.dart';

class EditFlashCardPage extends StatefulWidget {
  final String folderId;
  final String flashCardId;
  final String initialQuestion;
  final String initialAnswer;
  final Color color;

  const EditFlashCardPage({
    super.key,
    required this.folderId,
    required this.flashCardId,
    required this.initialQuestion,
    required this.initialAnswer,
    required this.color,
  });

  @override
  _EditFlashCardPageState createState() => _EditFlashCardPageState();
}

class _EditFlashCardPageState extends State<EditFlashCardPage> {
  late TextEditingController questionController;
  late TextEditingController answerController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.initialQuestion);
    answerController = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  Future<void> updateFlashCardInDb() async {
    try {
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .collection("questions")
          .doc(widget.flashCardId)
          .update({
        "question": questionController.text.trim(),
        "answer": answerController.text.trim(),
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteFlashCardFromDb() async {
    try {
      await FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.folderId)
          .collection("questions")
          .doc(widget.flashCardId)
          .delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  bool get _isFormValid {
    return questionController.text.trim().isNotEmpty &&
        answerController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        title: const Text(
          'Edit Flashcard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    controller: answerController,
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Answer',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    controller: questionController,
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Question',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 14,
                  ),
                  const SizedBox(height: 20),
                  buildRetroButton(
                    'Save Changes',
                    Colors.black,
                    _isLoading || !_isFormValid
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await updateFlashCardInDb();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Flashcard updated!'),
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
                  const SizedBox(height: 10),
                  buildRetroButton(
                    'Delete Flashcard',
                    Colors.red,
                    _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await deleteFlashCardFromDb();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Flashcard deleted!'),
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
