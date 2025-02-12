import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/utils/retro_button.dart';
import 'package:lottie/lottie.dart';

class ReelsPage extends StatelessWidget {
  final String userId;
  final Color color;

  const ReelsPage({super.key, required this.userId, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('folders').snapshots(),
        builder: (context, folderSnapshot) {
          if (folderSnapshot.connectionState == ConnectionState.waiting) {
            print('Fetching folders...');
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (!folderSnapshot.hasData || folderSnapshot.data!.docs.isEmpty) {
            return const EmptyFoldersWidget();
          }

          List<DocumentSnapshot> allFolders =
              folderSnapshot.data!.docs.where((folderDoc) {
            final folderData = folderDoc.data() as Map<String, dynamic>;
            final accessUsers = folderData['accessUsers'] as List<dynamic>;
            return folderData['creator'] == userId ||
                accessUsers.contains(userId);
          }).toList();

          List<Stream<QuerySnapshot>> questionStreams =
              allFolders.map((folderDoc) {
            return FirebaseFirestore.instance
                .collection('folders')
                .doc(folderDoc.id)
                .collection('questions')
                .snapshots();
          }).toList();

          return StreamBuilder<List<QuerySnapshot>>(
            stream: StreamZip(questionStreams),
            builder: (context, questionSnapshot) {
              if (questionSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (!questionSnapshot.hasData || questionSnapshot.data!.isEmpty) {
                return const EmptyFoldersWidget();
              }

              List<DocumentSnapshot> allQuestions = [];
              for (var querySnapshot in questionSnapshot.data!) {
                allQuestions.addAll(querySnapshot.docs);
              }

              if (allQuestions.isEmpty) {
                return const EmptyFoldersWidget(); // Use the new widget
              }

              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: allQuestions.length,
                itemBuilder: (context, index) {
                  final questionDoc = allQuestions[index];
                  final questionData =
                      questionDoc.data() as Map<String, dynamic>;

                  return QuestionCard(
                    question: questionData['question'],
                    answer: questionData['answer'],
                    color: color, // Pass the color to QuestionCard
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EmptyFoldersWidget extends StatelessWidget {
  const EmptyFoldersWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/tiktok.json',
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Turn your Tiktok scrolling time into learning time! Add your Questions to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final String question;
  final String answer;
  final Color color;

  const QuestionCard({
    required this.question,
    required this.answer,
    required this.color,
    super.key,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _showAnswer = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_showAnswer)
            Text(
              widget.answer,
              style: TextStyle(
                color: widget.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          buildRetroButton(
            _showAnswer ? 'Hide Answer' : 'Show Answer',
            widget.color,
            () {
              if (_isDisposed) return;
              setState(() {
                _showAnswer = !_showAnswer;
              });
            },
          ),
        ],
      ),
    );
  }
}
