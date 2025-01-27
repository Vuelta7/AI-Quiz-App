import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionModeModelWidget extends StatefulWidget {
  final List<Map<String, String>> questions;
  final String folderName;
  final String folderId;
  final Color headerColor;
  final bool isMultipleOptionMode;

  const QuestionModeModelWidget({
    super.key,
    required this.questions,
    required this.folderName,
    required this.folderId,
    required this.headerColor,
    this.isMultipleOptionMode = true,
  });

  @override
  State<QuestionModeModelWidget> createState() =>
      _QuestionModeModelWidgetState();
}

class _QuestionModeModelWidgetState extends State<QuestionModeModelWidget> {
  late PageController _pageController;
  int currentIndex = 0;
  int wrongAnswers = 0;
  String currentHint = '';
  List<int> wrongAnswerCount = [];
  List<String> attemptedAnswers = [];
  String feedbackMessage = 'Work Smart';
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<List<String>> cachedAnswers = [];
  List<String> positiveFeedback = [
    "Great Job!",
    "Well Done!",
    "Excellent!",
    "Keep it up!"
  ];

  List<String> negativeFeedback = [
    "Try Again!",
    "Oops, not quite!",
    "Incorrect, give it another shot!",
    "Almost there!"
  ];
  late Stopwatch _stopwatch;
  final FocusNode _focusNode = FocusNode();
  int hintCount = 0;
  bool isMultipleOptionMode = false;

  @override
  void initState() {
    super.initState();
    widget.questions.shuffle();
    _pageController = PageController();
    wrongAnswerCount = List.filled(widget.questions.length, 0);
    if (widget.isMultipleOptionMode) {
      for (var question in widget.questions) {
        String correctAnswer = question['answer']!;
        List<String> incorrectAnswers = widget.questions
            .where((q) => q['answer'] != correctAnswer)
            .map((q) => q['answer']!)
            .toSet()
            .toList();

        incorrectAnswers.shuffle();
        List<String> answers = [correctAnswer, ...incorrectAnswers.take(3)];
        answers.shuffle();
        cachedAnswers.add(answers);
      }
    }
    _stopwatch = Stopwatch()..start();
    _fetchHintCount();
    isMultipleOptionMode = widget.isMultipleOptionMode;
  }

  Future<void> _fetchHintCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();
      setState(() {
        hintCount = userSnapshot.data()?['hints'] ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void checkAnswer(String userAnswer) {
    final correctAnswer = widget.questions[currentIndex]['answer']!;

    if (widget.isMultipleOptionMode && attemptedAnswers.contains(userAnswer)) {
      return;
    }

    setState(() {
      if (userAnswer.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase()) {
        currentHint = '';
        _audioPlayer.play(AssetSource('correct_sf.mp3'));
        feedbackMessage =
            positiveFeedback[currentIndex % positiveFeedback.length];
        _nextQuestion();
      } else {
        wrongAnswers++;
        wrongAnswerCount[currentIndex]++;
        if (widget.isMultipleOptionMode) {
          attemptedAnswers.add(userAnswer);
        }
        _audioPlayer.play(AssetSource('wrong_sf.mp3'));

        feedbackMessage = negativeFeedback[
            wrongAnswerCount[currentIndex] % negativeFeedback.length];

        if (widget.isMultipleOptionMode && attemptedAnswers.length == 3) {
          feedbackMessage = 'Wrong, next question...';
          _nextQuestion();
        }
      }
    });
    if (!widget.isMultipleOptionMode) {
      _controller.clear();
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        attemptedAnswers.clear();
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

  void _showHint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();
      int hintCount = userSnapshot.data()?['hints'] ?? 0;

      if (hintCount > 0) {
        final answer = widget.questions[currentIndex]['answer']!;
        setState(() {
          if (currentHint.length < answer.length) {
            currentHint = answer.substring(0, currentHint.length + 1);
            userDoc.update({'hints': hintCount - 1});
            _fetchHintCount();
          } else {
            feedbackMessage = 'Hint maxed out';
          }
        });
      } else {
        setState(() {
          feedbackMessage = 'No hints left';
        });
      }
    }
  }

  void _showCompletionDialog() {
    _stopwatch.stop();
    final timeSpent = _stopwatch.elapsed.inSeconds;

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
                  "You've completed all questions.\n\nTotal Wrong Attempts: $wrongAnswers\nTime Spent: ${timeSpent}s",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _addPointsToUser(5);
                    await _updateLeaderboard(timeSpent);
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
                  onPressed: () async {
                    await _addPointsToUser(5);
                    await _updateLeaderboard(timeSpent);
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

  Future<void> _addPointsToUser(int points) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final currentRankPoints = snapshot.data()?['rankpoints'] ?? 0;
          final currentCurrencyPoints = snapshot.data()?['currencypoints'] ?? 0;
          transaction.update(userDoc, {
            'rankpoints': currentRankPoints + points,
            'currencypoints': currentCurrencyPoints + points,
          });
        }
      });
    }
  }

  Future<void> _updateLeaderboard(int timeSpent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();
      final username = userSnapshot.data()?['username'] ?? 'Unknown';

      final leaderboardDoc = FirebaseFirestore.instance
          .collection('folders')
          .doc(widget.folderId)
          .collection('leaderboard')
          .doc(userId);

      final leaderboardSnapshot = await leaderboardDoc.get();
      if (leaderboardSnapshot.exists) {
        final previousTimeSpent =
            leaderboardSnapshot.data()?['timeSpent'] ?? double.infinity;
        if (timeSpent < previousTimeSpent) {
          await leaderboardDoc.set({
            'username': username,
            'timeSpent': timeSpent,
          });
        }
      } else {
        await leaderboardDoc.set({
          'username': username,
          'timeSpent': timeSpent,
        });
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      currentIndex = 0;
      wrongAnswers = 0;
      currentHint = '';
      feedbackMessage = 'Work Smart';
      wrongAnswerCount = List.filled(widget.questions.length, 0);
      attemptedAnswers.clear();
      _pageController.jumpToPage(0);
      _stopwatch.reset();
      _stopwatch.start();
    });
  }

  void _finishQuiz() {
    Navigator.pop(context);
  }

  void _toggleMode() {
    setState(() {
      isMultipleOptionMode = !isMultipleOptionMode;
    });
  }

  Widget buildAnswerButtons() {
    List<String> answers = cachedAnswers[currentIndex];

    return Column(
      children: answers.map((answer) {
        Color buttonColor = attemptedAnswers.contains(answer)
            ? Colors.grey
            : widget.headerColor;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
            onPressed: () => checkAnswer(answer),
            child: Text(
              answer,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getTextColorForBackground(buttonColor),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

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
        actions: [
          IconButton(
            icon: Icon(
              isMultipleOptionMode ? Icons.text_fields : Icons.list,
              size: 30,
            ),
            color: Colors.black,
            onPressed: _toggleMode,
          ),
        ],
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
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feedbackMessage,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: feedbackMessage == 'Try Again!'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb,
                              color: Colors.black,
                              size: 22,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$hintCount',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                if (isMultipleOptionMode)
                  buildAnswerButtons()
                else
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: checkAnswer,
                    cursorColor: Colors.black,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type Answer',
                      hintStyle: const TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
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
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                    ),
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
