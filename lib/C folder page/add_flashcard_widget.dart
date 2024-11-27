import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/add_flashcard_screen.dart';

class AddFlashcardButtonWidget extends StatelessWidget {
  final String folderId;
  const AddFlashcardButtonWidget({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.add_box_rounded,
        size: 40,
      ),
      color: Colors.black,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddFlashCardScreen(
              folderId: folderId,
            );
          },
        );
      },
    );
  }
}
