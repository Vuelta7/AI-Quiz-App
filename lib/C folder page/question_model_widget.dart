import 'package:flutter/material.dart';

class QuestionModelWidget extends StatefulWidget {
  final List<Map<String, String>> questions;
  final String folderName;
  final String folderId;

  const QuestionModelWidget({
    super.key,
    required this.questions,
    required this.folderName,
    required this.folderId,
  });

  @override
  State<QuestionModelWidget> createState() => _QuestionModelWidgetState();
}

class _QuestionModelWidgetState extends State<QuestionModelWidget> {
  late PageController _pageController;
  int currentIndex = 0;
  int wrongAnswers = 0;
  String currentHint = '';
  List<int> wrongAnswerCount = [];

  @override
  void initState() {
    super.initState();
    widget.questions.shuffle();
    _pageController = PageController();
    wrongAnswerCount = List.filled(widget.questions.length, 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void checkAnswer(String userAnswer) {
    final correctAnswer = widget.questions[currentIndex]['question']!;
    if (userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      setState(() {
        currentHint = '';
      });
      _showSuccessEffect();
      _nextQuestion();
    } else {
      setState(() {
        wrongAnswers++;
        wrongAnswerCount[currentIndex]++;
      });
      _showErrorEffect();
    }
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      _pageController
          .jumpToPage(currentIndex + 1); // Directly jump to the next question
      setState(() {
        currentIndex++;
        currentHint = '';
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _previousQuestion() {
    if (currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        currentIndex--;
        currentHint = '';
      });
    }
  }

  void _showHint() {
    final answer = widget.questions[currentIndex]['question']!;
    setState(() {
      if (currentHint.isEmpty) {
        currentHint = '${answer[0]}_';
      } else if (currentHint.length < answer.length) {
        int revealedChars = currentHint.length;
        currentHint = '${answer.substring(0, revealedChars)}_';
      } else {
        currentHint = answer;
      }
    });
  }

  void _showSuccessEffect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Correct Answer!',
          style: TextStyle(color: Colors.green),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showErrorEffect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Wrong Answer. Try Again!',
          style: TextStyle(color: Colors.red),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "You've completed all questions.\n\nTotal Wrong Attempts: $wrongAnswers",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _restartQuiz(); // Restart the quiz
                    Navigator.pop(context); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Restart',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _finishQuiz(); // Finish the quiz
                    Navigator.pop(context); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _restartQuiz() {
    setState(() {
      currentIndex = 0;
      wrongAnswers = 0;
      currentHint = '';
      wrongAnswerCount = List.filled(widget.questions.length, 0);
      _pageController.jumpToPage(0);
    });
  }

  void _finishQuiz() {
    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.folderName,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 30),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / widget.questions.length,
              color: Colors.green,
              backgroundColor: Colors.grey,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final question = widget.questions[index];
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            width: 3,
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
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                currentHint.isNotEmpty ? currentHint : '_',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Divider(
                                thickness: 3,
                                color: Colors.black,
                              ),
                              Text(
                                question['answer']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        onSubmitted: checkAnswer,
                        cursorColor: const Color.fromARGB(255, 7, 7, 7),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Answer',
                          labelStyle: const TextStyle(
                            fontFamily: 'PressStart2P',
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 0, 0, 0),
                              width: 3,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 0, 0, 0),
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 0, 0, 0),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            iconSize: 45,
                            color: Colors.black,
                            onPressed: _previousQuestion,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.lightbulb,
                              size: 30,
                              color: Colors.black,
                            ),
                            onPressed: _showHint,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 45,
                              color: Colors.black,
                            ),
                            onPressed: _nextQuestion,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
