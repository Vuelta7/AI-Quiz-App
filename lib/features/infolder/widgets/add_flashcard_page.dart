import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/features/infolder/provider/flashcard_provider.dart';
import 'package:learn_n/features/infolder/widgets/auto_quiz.dart';
import 'package:lottie/lottie.dart';

class AddFlashCardPage extends ConsumerStatefulWidget {
  final String folderId;
  final Color color;

  const AddFlashCardPage({
    super.key,
    required this.folderId,
    required this.color,
  });

  @override
  ConsumerState<AddFlashCardPage> createState() => _AddFlashCardPageState();
}

class _AddFlashCardPageState extends ConsumerState<AddFlashCardPage> {
  final answerController = TextEditingController();
  final questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    answerController.dispose();
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardService = ref.read(flashcardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(
          'Flashcard Manager',
          style: TextStyle(
            color: getColorForTextAndIcon(widget.color),
            fontSize: 16,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: getColorForTextAndIcon(widget.color),
          ),
        ),
      ),
      backgroundColor: widget.color,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
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
                        backgroundColor: widget.color,
                        title: Text(
                          'Add Flashcard',
                          style: TextStyle(
                            color: getColorForTextAndIcon(widget.color),
                            fontFamily: 'PressStart2P',
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: questionController,
                              style: TextStyle(
                                color: getColorForTextAndIcon(widget.color),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Question or Definition',
                                hintStyle: TextStyle(
                                  color: getColorForTextAndIcon(widget.color),
                                ),
                              ),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: answerController,
                              style: TextStyle(
                                color: getColorForTextAndIcon(widget.color),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Answer',
                                hintStyle: TextStyle(
                                  color: getColorForTextAndIcon(widget.color),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: getColorForTextAndIcon(widget.color),
                                fontFamily: 'PressStart2P',
                              ),
                            ),
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
                                await flashcardService.upload(
                                  widget.folderId,
                                  questionController.text.trim(),
                                  answerController.text.trim(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Flashcard added successfully!')),
                                );
                                questionController.clear();
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
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: getColorForTextAndIcon(widget.color),
                                fontFamily: 'PressStart2P',
                              ),
                            ),
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
              Text(
                "Existing Flashcards:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: getColorForTextAndIcon(widget.color),
                  fontFamily: 'PressStart2P',
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: flashcardService.getFlashcards(widget.folderId),
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
                            Lottie.asset('assets/lottie/makequiz.json'),
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
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                    labelText: 'Question'),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: answerController,
                                style: const TextStyle(color: Colors.white),
                                decoration:
                                    const InputDecoration(labelText: 'Answer'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.save,
                                        color: Colors.white),
                                    onPressed: () async {
                                      await flashcardService.update(
                                        widget.folderId,
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
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () async {
                                      await flashcardService.delete(
                                          widget.folderId, flashcard.id);
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
    );
  }
}
