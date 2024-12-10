import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FlashCardModel extends StatefulWidget {
  final String question;
  final String answer;
  final String questionId;
  final String folderId;

  const FlashCardModel({
    super.key,
    required this.question,
    required this.answer,
    required this.questionId,
    required this.folderId,
  });

  @override
  _FlashCardModelState createState() => _FlashCardModelState();
}

class _FlashCardModelState extends State<FlashCardModel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.isCompleted) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        });
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.rotationY(_animation.value * 3.14159),
                alignment: Alignment.center,
                child: _buildCard(),
              );
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 310,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          width: 4,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildFront(),
          _buildBack(),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return Visibility(
      visible: _animation.value < 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.question,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFlashCardWidget(
                        folderId: widget.folderId,
                        flashCardId: widget.questionId,
                        initialQuestion: widget.question,
                        initialAnswer: widget.answer,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Visibility(
      visible: _animation.value >= 0.5,
      child: Transform(
        transform: Matrix4.rotationY(_animation.value < 0.5 ? 0 : 3.14159),
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.answer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFlashCardWidget(
                        folderId: widget.folderId,
                        flashCardId: widget.questionId,
                        initialQuestion: widget.question,
                        initialAnswer: widget.answer,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditFlashCardWidget extends StatefulWidget {
  final String folderId;
  final String flashCardId;
  final String initialQuestion;
  final String initialAnswer;

  const EditFlashCardWidget({
    super.key,
    required this.folderId,
    required this.flashCardId,
    required this.initialQuestion,
    required this.initialAnswer,
  });

  @override
  _EditFlashCardWidgetState createState() => _EditFlashCardWidgetState();
}

class _EditFlashCardWidgetState extends State<EditFlashCardWidget> {
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
        title: const Text(
          'Edit Flashcard',
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
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      hintText: 'Answer',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: questionController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      hintText: 'Question',
                    ),
                    maxLines: 14,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading || !_isFormValid
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Delete Flashcard',
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
