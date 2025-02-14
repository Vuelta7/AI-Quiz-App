import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/components/loading.dart';
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
  bool _isAddingFlashcard = false; // Default to Magic Import
  final GeminiService gemini = GeminiService();
  String extractedText = "Select a PDF to extract text.";
  List<Map<String, String>> questionsAndAnswers = [];
  TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    answerController.dispose();
    questionController.dispose();
    super.dispose();
  }

  Color getShade(Color color, int shade) {
    return color.withOpacity(shade / 1000);
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

        generateQuestionsFromText(text);
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

  Future<void> generateQuestionsFromText(String text) async {
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
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAddingFlashcard = true;
                        });
                      },
                      child: Container(
                        color: _isAddingFlashcard
                            ? Colors.white
                            : getShade(Colors.black, 300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Add Flashcard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isAddingFlashcard
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAddingFlashcard = false;
                        });
                      },
                      child: Container(
                        color: !_isAddingFlashcard
                            ? Colors.white
                            : getShade(Colors.black, 300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Magic Import',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isAddingFlashcard
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        _isAddingFlashcard
                            ? Column(
                                children: [
                                  TextFormField(
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    controller: answerController,
                                    decoration: const InputDecoration(
                                      hintText: 'Answer',
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
                                    cursorColor: Colors.black,
                                    decoration: const InputDecoration(
                                      hintText: 'Question or Definition',
                                      border: InputBorder.none,
                                    ),
                                    maxLines: 14,
                                  ),
                                  const SizedBox(height: 10),
                                  buildRetroButton(
                                    'SUBMIT',
                                    getShade(Colors.black, 300),
                                    _isLoading
                                        ? null
                                        : () async {
                                            if (answerController.text
                                                .trim()
                                                .isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please enter a question.'),
                                                ),
                                              );
                                              return;
                                            }
                                            if (questionController.text
                                                .trim()
                                                .isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please enter an answer.'),
                                                ),
                                              );
                                              return;
                                            }
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            try {
                                              await uploadFlashCardToDb();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Flashcard added successfully!'),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text('Error: $e')),
                                              );
                                            } finally {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          },
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildRetroButton(
                                      'Pick PDF',
                                      getShade(Colors.black, 300),
                                      pickAndExtractText,
                                      icon: Icons.picture_as_pdf,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: textController,
                                      maxLines: 5,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Or paste your text here",
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    buildRetroButton(
                                      'Generate Questions from Text',
                                      getShade(Colors.black, 300),
                                      () {
                                        generateQuestionsFromText(
                                            textController.text);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Extracted Questions:",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    questionsAndAnswers.isNotEmpty
                                        ? SizedBox(
                                            height:
                                                300, // Define a height for the ListView
                                            child: ListView.builder(
                                              itemCount:
                                                  questionsAndAnswers.length,
                                              itemBuilder: (context, index) {
                                                final qa =
                                                    questionsAndAnswers[index];
                                                return Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Q: ${qa['question']}",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                            "A: ${qa['answer']}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : const Text("No questions generated."),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) const Loading(),
        ],
      ),
    );
  }
}
