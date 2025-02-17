import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/components/loading.dart';
import 'package:learn_n/services/gemini_service.dart';
import 'package:learn_n/utils/color_utils.dart';
import 'package:learn_n/utils/retro_button.dart';

class AutoQuizPage extends StatefulWidget {
  final String folderId;
  final Color color;

  const AutoQuizPage({super.key, required this.folderId, required this.color});

  @override
  State<AutoQuizPage> createState() => _AutoQuizPageState();
}

class _AutoQuizPageState extends State<AutoQuizPage> {
  final GeminiService gemini = GeminiService();
  bool _isLoading = false;
  String extractedText = "Select a PDF to extract text.";
  List<Map<String, String>> questionsAndAnswers = [];
  TextEditingController textController = TextEditingController();
  TextEditingController promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> generateQuestionsFromText(
      String text, String customPrompt) async {
    String defaultPrompt =
        "Generate questions and answers, keep the answer short for example(1 to 3 words only) from the following text. Format it as a valid Dart list of maps like this: [{ \"question\": \"...\", \"answer\": \"...\" }, ...]. Text: $text";
    String prompt = customPrompt.isNotEmpty
        ? "$defaultPrompt $customPrompt"
        : defaultPrompt;

    try {
      String? response = await gemini.sendMessage(prompt);

      if (response != null) {
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
      }
    } catch (e) {
      setState(() {
        extractedText = "Failed to parse response: $e";
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        title: const Text(
          'Automatic Quiz Generation',
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
                TextField(
                  controller: promptController,
                  decoration: const InputDecoration(
                    hintText: 'Custom Prompt (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                buildRetroButton(
                  'Generate Questions from Clipboard',
                  getShade(widget.color, 300),
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
                                setState(() {
                                  _isLoading = true;
                                });
                                await generateQuestionsFromText(
                                    textController.text, promptController.text);
                                setState(() {
                                  _isLoading = false;
                                });
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
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
                  "Extracted Questions:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                questionsAndAnswers.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questionsAndAnswers.length,
                        itemBuilder: (context, index) {
                          final qa = questionsAndAnswers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    qa['question'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(qa['answer'] ?? ''),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Text("No questions generated."),
                const SizedBox(height: 16),
                buildRetroButton(
                  'Save to Folder',
                  getShade(widget.color, 300),
                  () {
                    for (var qa in questionsAndAnswers) {
                      saveQuestionToFirestore(
                          widget.folderId, qa['question']!, qa['answer']!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Questions saved!')),
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
