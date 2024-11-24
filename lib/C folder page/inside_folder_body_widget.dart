import 'package:flutter/material.dart';
import 'package:learn_n/model%20widgets/flashcard_model_widget.dart';

class InsideFolderBodyWidget extends StatelessWidget {
  const InsideFolderBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            FlashCardModelWidget(
              title: "What is Flutter?",
              backContent:
                  "Flutter is an open-source UI software development toolkit created by Google.",
            ),
            FlashCardModelWidget(
              title: "What is programming?",
              backContent: "ewan diko alam",
            ),
          ],
        ),
      ),
    );
  }
}
