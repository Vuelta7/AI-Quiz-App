import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_appbar_widget.dart';
import 'package:learn_n/model%20widgets/flashcard_model_widget.dart';
import 'package:learn_n/model%20widgets/question_model_widget.dart';

class InsideFolderMain extends StatelessWidget {
  final String folderId;
  const InsideFolderMain({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: insideFolderAppBarWidget(context, folderId: folderId),
      body: InsideFolderBody(folderId: folderId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          try {
            // Fetch questions from Firestore
            final questionsSnapshot = await FirebaseFirestore.instance
                .collection('folders')
                .doc(folderId)
                .collection('questions')
                .get();

            // Convert snapshot to a list of question data
            final questions = questionsSnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                "id": doc.id,
                "question": data['question']?.toString() ?? '',
                "answer": data['answer']?.toString() ?? '',
              };
            }).toList();

            // Navigate to QuestionModelWidget with fetched questions
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionModelWidget(
                  folderId: folderId,
                  questions: List<Map<String, String>>.from(questions),
                ),
              ),
            );
          } catch (e) {
            // Handle any potential errors
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
// TextField(
//                   cursorColor: const Color.fromARGB(255, 7, 7, 7),
//                   style: const TextStyle(
//                     fontFamily: 'Arial',
//                     color: Color.fromARGB(255, 0, 0, 0),
//                     fontSize: 14,
//                   ),
//                   decoration: InputDecoration(
//                     labelText: 'Answer',
//                     labelStyle: const TextStyle(
//                       fontFamily: 'PressStart2P',
//                       color: Color.fromARGB(255, 0, 0, 0),
//                     ),
//                     filled: true,
//                     fillColor: const Color.fromARGB(255, 255, 255, 255),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 0, 0, 0),
//                         width: 3,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 0, 0, 0),
//                         width: 3,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 0, 0, 0),
//                         width: 3,
//                       ),
//                     ),
//                   ),
//                 ),