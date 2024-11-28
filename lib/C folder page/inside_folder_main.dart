import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_appbar_widget.dart';
import 'package:learn_n/model%20widgets/flashcard_model_widget.dart';
import 'package:learn_n/model%20widgets/question_model_widget.dart';

class InsideFolderMain extends StatelessWidget {
  final String folderId;
  final String folderName;
  const InsideFolderMain(
      {super.key, required this.folderId, required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: insideFolderAppBarWidget(context,
          folderId: folderId, folderName: folderName),
      body: InsideFolderBody(folderId: folderId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          try {
            final questionsSnapshot = await FirebaseFirestore.instance
                .collection('folders')
                .doc(folderId)
                .collection('questions')
                .get();

            final questions = questionsSnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                "id": doc.id,
                "question": data['question']?.toString() ?? '',
                "answer": data['answer']?.toString() ?? '',
              };
            }).toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionModelWidget(
                  folderName: folderName,
                  folderId: folderId,
                  questions: List<Map<String, String>>.from(questions),
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load questions: $e')),
            );
          }
        },
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.hexagon_rounded,
              size: 80,
              color: Colors.black,
            ),
            Icon(
              Icons.play_arrow,
              size: 40,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class InsideFolderBody extends StatelessWidget {
  final String folderId;

  const InsideFolderBody({super.key, required this.folderId});

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
                questionId: questionDoc.id,
                folderId: folderId,
              ),
            );
          },
        );
      },
    );
  }
}
