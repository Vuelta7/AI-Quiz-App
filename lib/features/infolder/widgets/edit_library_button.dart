import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/features/infolder/widgets/add_flashcard_page.dart';

class EditLibraryButton extends StatelessWidget {
  final Color color;
  final String folderId;
  const EditLibraryButton(
      {super.key, required this.color, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
        horizontal: 6.0,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFlashCardPage(
                folderId: folderId,
                color: color,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Edit Library',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: getShade(color, 800),
          ),
        ),
      ),
    );
  }
}
