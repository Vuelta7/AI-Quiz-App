import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/features/infolder/widgets/flashcard_model.dart';
import 'package:lottie/lottie.dart';

class FlashcardsPage extends StatelessWidget {
  final String folderId;
  final bool isEditing;
  final Color color;

  const FlashcardsPage({
    super.key,
    required this.folderId,
    this.isEditing = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId)
          .collection('questions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/makequiz.json',
                  ),
                  Text(
                    'No Flashcards here!\nCreate one by clicking the\n"Edit library"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          color: getShade(color, 500),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final questionDoc = snapshot.data!.docs[index];
            final questionData = questionDoc.data() as Map<String, dynamic>;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: FlashCardModel(
                question: questionData['question'],
                answer: questionData['answer'],
                questionId: questionDoc.id,
                folderId: folderId,
                color: color,
              ),
            );
          },
        );
      },
    );
  }
}
