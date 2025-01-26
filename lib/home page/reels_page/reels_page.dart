import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReelsPage extends StatelessWidget {
  final String userId;

  const ReelsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reels',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
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
            print('No folders found.');
            return const Center(
              child: Text(
                'No questions available.',
                style: TextStyle(color: Colors.white),
              ),
            );
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
            print('Fetching questions for folder: ${folderDoc.id}');
            return FirebaseFirestore.instance
                .collection('folders')
                .doc(folderDoc.id)
                .collection('questions')
                .snapshots();
          }).toList();
          print('Total folders: ${questionStreams.length}');

          return StreamBuilder<List<QuerySnapshot>>(
            stream: StreamZip(questionStreams),
            builder: (context, questionSnapshot) {
              if (questionSnapshot.connectionState == ConnectionState.waiting) {
                print('Fetching questions...');
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (!questionSnapshot.hasData || questionSnapshot.data!.isEmpty) {
                print('No questions found.');
                return const Center(
                  child: Text(
                    'No questions available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              List<DocumentSnapshot> allQuestions = [];
              for (var querySnapshot in questionSnapshot.data!) {
                allQuestions.addAll(querySnapshot.docs);
              }
              print('Total questions: ${allQuestions.length}');

              if (allQuestions.isEmpty) {
                print('No questions available after merging.');
                return const Center(
                  child: Text(
                    'No questions available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
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

class QuestionCard extends StatefulWidget {
  final String question;
  final String answer;

  const QuestionCard({
    required this.question,
    required this.answer,
    super.key,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _showAnswer = false;
  bool _isDisposed = false; // Add this flag

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.question,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_showAnswer)
            Text(
              widget.answer,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_isDisposed) return; // Check if the widget is disposed
              setState(() {
                _showAnswer = !_showAnswer;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text(_showAnswer ? 'Hide Answer' : 'Show Answer'),
          ),
        ],
      ),
    );
  }
}
