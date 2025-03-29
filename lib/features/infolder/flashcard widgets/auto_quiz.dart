import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:learn_n/services/gemini_service.dart';
import 'package:lottie/lottie.dart';

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
  bool _isTimeout = false;
  List<Map<String, String>> questionsAndAnswers = [];
  TextEditingController textController = TextEditingController();
  TextEditingController promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> generateQuestionsFromText(
      String text, String customPrompt) async {
    setState(() {
      _isLoading = true;
      _isTimeout = false;
    });

    String defaultPrompt =
        "Generate questions and answers (must only contain 4-word maximum answer) from the following text. Format it as a valid Dart list of maps like this: [{ \"question\": \"...\", \"answer\": \"...\" }, ...]. Text: $text";
    String prompt = customPrompt.isNotEmpty
        ? "$defaultPrompt $customPrompt"
        : defaultPrompt;

    Timer timeoutTimer = Timer(const Duration(seconds: 13), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isTimeout = true;
        });
      }
    });

    try {
      String? response = await gemini.sendMessage(prompt);
      timeoutTimer.cancel();
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
            _isLoading = false;
          });
        } else {
          throw Exception("Response is not a List format.");
        }
      }
    } catch (e) {
      timeoutTimer.cancel();
      setState(() {
        _isLoading = false;
        _isTimeout = true;
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
          'Generate Quiz',
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
        actions: [
          if (questionsAndAnswers.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
              onPressed: () {
                for (var qa in questionsAndAnswers) {
                  saveQuestionToFirestore(
                      widget.folderId, qa['question']!, qa['answer']!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Questions saved!')),
                );
              },
            ),
        ],
      ),
      backgroundColor: widget.color,
      body: _isLoading
          ? const Center(
              child: Loading(),
            )
          : _isTimeout
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Learn-N got cooked generating quiz (Error)!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'PressStart2P',
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildRetroButton(
                          'Try Again',
                          getShade(widget.color, 300),
                          () {
                            generateQuestionsFromText(
                                textController.text, promptController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          if (questionsAndAnswers.isEmpty) ...[
                            TextField(
                              controller: textController,
                              maxLines: 7,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Paste your text here",
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'PressStart2P',
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              controller: promptController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Custom Prompt (Optional)",
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'PressStart2P',
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            buildRetroButton(
                              'Generate Questions from Text',
                              getShade(widget.color, 300),
                              () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await generateQuestionsFromText(
                                    textController.text, promptController.text);
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/makequiz.json',
                                    ),
                                    const Text(
                                      'Generate by copy and pasting your notes in textfield then press the "Generate Questions from Text", then wait for few seconds.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'PressStart2P',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (questionsAndAnswers.isNotEmpty) ...[
                            const Text(
                              "Extracted Questions:",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'PressStart2P',
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: questionsAndAnswers.length,
                              itemBuilder: (context, index) {
                                final qa = questionsAndAnswers[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            ),
                            const SizedBox(height: 10),
                            buildRetroButton(
                              'Save to Folder',
                              getShade(widget.color, 300),
                              () {
                                for (var qa in questionsAndAnswers) {
                                  saveQuestionToFirestore(widget.folderId,
                                      qa['question']!, qa['answer']!);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Questions saved!')),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
