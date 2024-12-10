import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class QuestionMultipleOptionModeModelWidget extends StatefulWidget {
  final List<Map<String, String>> questions;
  final String folderName;
  final String folderId;
  final Color headerColor;

  const QuestionMultipleOptionModeModelWidget({
    super.key,
    required this.questions,
    required this.folderName,
    required this.folderId,
    required this.headerColor,
  });

  @override
  State<QuestionMultipleOptionModeModelWidget> createState() =>
      _QuestionMultipleOptionModeModelWidgetState();
}

class _QuestionMultipleOptionModeModelWidgetState
    extends State<QuestionMultipleOptionModeModelWidget> {
  late PageController _pageController;
  int currentIndex = 0;
  int wrongAnswers = 0;
  String currentHint = '';
  List<int> wrongAnswerCount = [];
  String feedbackMessage = 'Work Smart';
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _controller.dispose();
    super.dispose();
  }

  void checkAnswer(String userAnswer) {
    final correctAnswer = widget.questions[currentIndex]['answer']!;
    setState(() {
      if (userAnswer.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase()) {
        currentHint = '';
        _audioPlayer.play(AssetSource('correct_sf.mp3'));

        final positiveFeedback = [
          'Awesome!',
          'Great Job!',
          'Keep it up!',
          'You got it!',
          'Excellent!'
        ];
        feedbackMessage =
            positiveFeedback[currentIndex % positiveFeedback.length];
        _nextQuestion();
      } else {
        wrongAnswers++;
        wrongAnswerCount[currentIndex]++;
        _audioPlayer.play(AssetSource('wrong_sf.mp3'));

        final negativeFeedback = [
          'Not quite!',
          'Try Again!',
          'Oops, wrong one!',
          'Don’t give up!',
          'Keep trying!'
        ];
        feedbackMessage =
            negativeFeedback[currentIndex % negativeFeedback.length];
      }
    });
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        currentHint = 'Work Smart';
        currentHint = '';
      });
      _pageController.jumpToPage(currentIndex);
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
        feedbackMessage = '';
      });
    }
  }

  void _showHint() {
    final answer = widget.questions[currentIndex]['answer']!;
    setState(() {
      if (currentHint.isEmpty) {
        currentHint = '${answer[0]}_';
      } else if (currentHint.length < answer.length - 1) {
        int revealedChars = currentHint.length;
        currentHint = '${answer.substring(0, revealedChars)}_';
      } else {
        currentHint = answer;
        _nextQuestion();
      }
    });
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
                    _restartQuiz();
                    Navigator.pop(context);
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
                    _finishQuiz();
                    Navigator.pop(context);
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
      feedbackMessage = 'Work Smart';
      wrongAnswerCount = List.filled(widget.questions.length, 0);
      _pageController.jumpToPage(0);
    });
  }

  void _finishQuiz() {
    Navigator.pop(context);
  }

  Widget buildAnswerButtons() {
    String correctAnswer = widget.questions[currentIndex]['answer']!;

    // Collect all unique answers except the correct one
    List<String> incorrectAnswers = widget.questions
        .where((q) => q['answer'] != correctAnswer)
        .map((q) => q['answer']!)
        .toSet()
        .toList();

    // Select 3 random incorrect answers
    incorrectAnswers.shuffle();
    List<String> answers = [correctAnswer, ...incorrectAnswers.take(3)];

    answers.shuffle(); // Shuffle for randomness

    return Column(
      children: answers.map((answer) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.headerColor,
            ),
            onPressed: () => checkAnswer(answer),
            child: Text(
              answer,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getTextColorForBackground(widget.headerColor),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

// Function to determine appropriate text color based on background color
  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 10,
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / widget.questions.length,
              color: widget.headerColor,
              backgroundColor: Colors.grey,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Expanded(
                    child: Center(
                      child: Text(
                        feedbackMessage,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: feedbackMessage == 'Try Again!'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
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
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.black,
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentHint.isNotEmpty
                                          ? currentHint
                                          : '_',
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        question['question']!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // answer area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: buildAnswerButtons(),
                ),
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
          ),
        ],
      ),
    );
  }
}
