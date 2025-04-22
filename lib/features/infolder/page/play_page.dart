import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/learnn_icon.dart';
import 'package:learn_n/core/widgets/learnn_text.dart';
import 'package:learn_n/features/infolder/infolder_main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayPage extends StatefulWidget {
  final List<Map<String, String>> questions;
  final String folderName;
  final String folderId;
  final Color color;
  final bool isMultipleOptionMode;
  final bool isImported;

  const PlayPage({
    super.key,
    required this.questions,
    required this.folderName,
    required this.folderId,
    required this.color,
    this.isMultipleOptionMode = true,
    required this.isImported,
  });

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
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
    "give it another shot!",
    "Almost there!"
  ];
  late Stopwatch _stopwatch;
  final FocusNode _focusNode = FocusNode();
  int hintCount = 0;
  bool isMultipleOptionMode = false;
  Color? selectedColor;

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
    _loadModePreference();
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

  Future<void> _loadModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMultipleOptionMode =
          prefs.getBool('isMultipleOptionMode') ?? widget.isMultipleOptionMode;
    });
  }

  Future<void> _saveModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMultipleOptionMode', isMultipleOptionMode);
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
          child: Stack(
            children: [
              Lottie.asset(
                'assets/confetti.json',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Padding(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InFolderMain(
                              folderName: widget.folderName,
                              folderId: widget.folderId,
                              color: widget.color,
                              isImported: widget.isImported,
                            ),
                          ),
                        );
                        await _addPointsToUser(20);
                        await _updateLeaderboard(timeSpent);
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
            ],
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
          final currentCurrencyPoints = snapshot.data()?['currencypoints'] ?? 0;
          transaction.update(userDoc, {
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

  void _toggleMode() {
    setState(() {
      isMultipleOptionMode = !isMultipleOptionMode;
      _saveModePreference();
    });
  }

  Widget buildAnswerButtons() {
    List<String> answers = cachedAnswers[currentIndex];

    return Column(
      children: answers.map((answer) {
        Color buttonColor =
            attemptedAnswers.contains(answer) ? Colors.grey : widget.color;

        return Container(
          padding: const EdgeInsets.all(4.0),
          decoration: const BoxDecoration(),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(15),
              backgroundColor: buttonColor,
              side: BorderSide(
                  color: getColorForTextAndIcon(widget.color), width: 3),
            ),
            onPressed: () => checkAnswer(answer),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                answer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: getColorForTextAndIcon(buttonColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      color: getShade(widget.color, 500),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: widget.color,
        title: LearnNText(
          fontSize: 16,
          text: widget.folderName,
          font: 'PressStart2P',
          color: getColorForTextAndIcon(widget.color),
          backgroundColor: getShade(
            widget.color,
            500,
          ),
        ),
        leading: IconButton(
          icon: LearnNIcon(
            icon: Icons.arrow_back,
            color: getColorForTextAndIcon(widget.color),
            shadowColor: getShade(widget.color, 500),
            size: 45,
          ),
          color: getColorForTextAndIcon(widget.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: LearnNIcon(
              icon: isMultipleOptionMode ? Icons.text_fields : Icons.list,
              color: getColorForTextAndIcon(widget.color),
              shadowColor: getShade(widget.color, 500),
              size: 45,
            ),
            onPressed: _toggleMode,
          ),
        ],
      ),
      backgroundColor: widget.color,
      body: Column(
        children: [
          Material(
            elevation: 2,
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / widget.questions.length,
                color: Colors.green,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LearnNText(
                          fontSize: 16,
                          text: feedbackMessage,
                          font: 'PressStart2P',
                          color: feedbackMessage == 'Try Again!'
                              ? Colors.red
                              : getColorForTextAndIcon(widget.color),
                          backgroundColor: getShade(
                            widget.color,
                            500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            LearnNIcon(
                              icon: Icons.lightbulb,
                              color: getColorForTextAndIcon(widget.color),
                              shadowColor: getShade(widget.color, 500),
                              size: 22,
                            ),
                            const SizedBox(width: 5),
                            LearnNText(
                              fontSize: 16,
                              text: hintCount.toString(),
                              font: 'PressStart2P',
                              color: getColorForTextAndIcon(widget.color),
                              backgroundColor: getShade(
                                widget.color,
                                500,
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
                              child: Material(
                                borderOnForeground: true,
                                elevation: 2,
                                borderRadius: BorderRadius.circular(9),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget.color,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      width: 3,
                                      color:
                                          getColorForTextAndIcon(widget.color),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentHint.isNotEmpty
                                            ? currentHint
                                            : '_',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: getColorForTextAndIcon(
                                              widget.color),
                                          shadows: [
                                            Shadow(
                                              offset: const Offset(2, 2),
                                              color:
                                                  getShade(widget.color, 500),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Divider(
                                        thickness: 3,
                                        color: getColorForTextAndIcon(
                                            widget.color),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: SingleChildScrollView(
                                            child: Text(
                                              question['question']!,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: getColorForTextAndIcon(
                                                    widget.color),
                                                shadows: [
                                                  Shadow(
                                                    offset: const Offset(2, 2),
                                                    color: getShade(
                                                        widget.color, 500),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
          Expanded(
            child: SingleChildScrollView(
              child: isMultipleOptionMode
                  ? buildAnswerButtons()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onSubmitted: checkAnswer,
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
                            fillColor: widget.color,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: getColorForTextAndIcon(widget.color),
                                width: 3,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: getColorForTextAndIcon(widget.color),
                                width: 3,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: getColorForTextAndIcon(widget.color),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: LearnNIcon(
                  icon: Icons.arrow_back_rounded,
                  color: getColorForTextAndIcon(widget.color),
                  shadowColor: getShade(widget.color, 500),
                  size: 45,
                ),
                onPressed: _previousQuestion,
              ),
              IconButton(
                icon: LearnNIcon(
                  icon: Icons.lightbulb,
                  color: getColorForTextAndIcon(widget.color),
                  shadowColor: getShade(widget.color, 500),
                  size: 45,
                ),
                onPressed: _showHint,
              ),
              IconButton(
                icon: LearnNIcon(
                  icon: Icons.arrow_forward_rounded,
                  color: getColorForTextAndIcon(widget.color),
                  shadowColor: getShade(widget.color, 500),
                  size: 45,
                ),
                onPressed: _nextQuestion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
