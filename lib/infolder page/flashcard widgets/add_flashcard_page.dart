import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/services/gemini_service.dart';
import 'package:learn_n/utils/retro_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
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
  final GeminiService gemini = GeminiService();
  String extractedText = "Select a PDF to extract text.";
  List<Map<String, String>> questionsAndAnswers = [];
  TextEditingController textController = TextEditingController();
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

  Color getShade(Color color, int shade) {
    return color.withOpacity(shade / 1000);
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
                  getShade(Colors.black, 300),
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
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Text(
                  'Automatic Generate Quiz:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                buildRetroButton(
                  'Pick PDF',
                  getShade(Colors.black, 300),
                  () async {
                    await pickAndExtractText();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Extracted Questions'),
                          content: SizedBox(
                            height: 400,
                            width: double.maxFinite,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: questionsAndAnswers.length,
                                    itemBuilder: (context, index) {
                                      final qa = questionsAndAnswers[index];
                                      return ListTile(
                                        title: Text(qa['question'] ?? ''),
                                        subtitle: Text(qa['answer'] ?? ''),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                for (var qa in questionsAndAnswers) {
                                  saveQuestionToFirestore(widget.folderId,
                                      qa['question']!, qa['answer']!);
                                }
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Questions saved!')),
                                );
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icons.picture_as_pdf,
                ),
                const SizedBox(
                  height: 5,
                ),
                buildRetroButton(
                  'Paste from Clipboard',
                  icon: Icons.paste,
                  getShade(Colors.black, 300),
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title:
                              const Text('Generate Questions from Clipboard'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: textController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Paste your text here",
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'PressStart2P',
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
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await generateQuestionsFromClipboard(
                                    textController.text);
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Extracted Questions'),
                                      content: SizedBox(
                                        height: 400,
                                        width: double.maxFinite,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    questionsAndAnswers.length,
                                                itemBuilder: (context, index) {
                                                  final qa =
                                                      questionsAndAnswers[
                                                          index];
                                                  return ListTile(
                                                    title: Text(
                                                        qa['question'] ?? ''),
                                                    subtitle: Text(
                                                        qa['answer'] ?? ''),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            for (var qa
                                                in questionsAndAnswers) {
                                              saveQuestionToFirestore(
                                                  widget.folderId,
                                                  qa['question']!,
                                                  qa['answer']!);
                                            }
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Questions saved!')),
                                            );
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text('Generate'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Existing Flashcards:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No flashcards found.");
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
                          color: getShade(Colors.black, 300),
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
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<void> pickAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);

      try {
        final PdfDocument pdfDoc =
            PdfDocument(inputBytes: file.readAsBytesSync());
        String text = "";
        for (int i = 0; i < pdfDoc.pages.count; i++) {
          PdfTextExtractor extractor = PdfTextExtractor(pdfDoc);
          text += "${extractor.extractText()}\n\n";
        }

        setState(() {
          extractedText = text.isNotEmpty ? text : "No text found in PDF.";
        });

        pdfDoc.dispose();

        generateQuestionsFromClipboard(text);
      } catch (e) {
        setState(() {
          extractedText = "Error reading PDF: $e";
        });
      }
    } else {
      setState(() {
        extractedText = "No file selected.";
      });
    }
  }

  Future<void> generateQuestionsFromClipboard(String text) async {
    String prompt =
        "Generate questions and answers, keep the answer short for example(1 to 3 words only) from the following text. Format it as a valid Dart list of maps like this: [{ \"question\": \"...\", \"answer\": \"...\" }, ...]. Text: $text";

    String? response = await gemini.sendMessage(prompt);

    if (response != null) {
      try {
        response = response.trim();
        if (response.startsWith("```json")) {
          response =
              response.replaceAll("```json", "").replaceAll("```", "").trim();
        }
        if (response.startsWith("```dart")) {
          response =
              response.replaceAll("```dart", "").replaceAll("```", "").trim();
        }

        var decodedData = jsonDecode(response);

        if (decodedData is List) {
          setState(() {
            questionsAndAnswers = List<Map<String, String>>.from(
                decodedData.map((item) => Map<String, String>.from(item)));
          });
        } else {
          throw Exception("Response is not a List format.");
        }
      } catch (e) {
        setState(() {
          extractedText = "Failed to parse response: $e";
        });
      }
    }
  }

  Future<void> saveQuestionToFirestore(
      String folderId, String question, String answer) async {
    try {
      String id = FirebaseFirestore.instance
          .collection("folders")
          .doc(folderId)
          .collection("questions")
          .doc()
          .id;

      await FirebaseFirestore.instance
          .collection("folders")
          .doc(folderId)
          .collection("questions")
          .doc(id)
          .set({
        "question": question.trim(),
        "answer": answer.trim(),
      });

      print("Question saved successfully!");
    } catch (e) {
      print("Error saving question: $e");
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
}
