import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('folders')
            .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, folderSnapshot) {
          if (folderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (!folderSnapshot.hasData || folderSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No questions available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          List<Stream<QuerySnapshot>> questionStreams =
              folderSnapshot.data!.docs.map((folderDoc) {
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
