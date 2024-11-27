import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/model%20widgets/flashcard_model_widget.dart';

class InsideFolderBody extends StatelessWidget {
  final String folderId;

  const InsideFolderBody({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('folders')
          .doc(folderId) // Reference the specific folder
          .collection('questions') // Subcollection of the folder
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No questions found :<'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final questionDoc = snapshot.data!.docs[index];
            final questionData = questionDoc.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FlashCardModel(
                question: questionData['question'],
                answer: questionData['answer'],
                questionId: questionDoc.id, // Pass question ID
                folderId: folderId, // Pass folder ID
              ),
            );
          },
        );
      },
    );
  }
}
