import 'package:flutter/material.dart';
import 'package:learn_n/C%20infolder%20page/play%20page/question_multiple_option_model_widget.dart';
import 'package:learn_n/C%20infolder%20page/play%20page/question_typing_mode_model_widget.dart';

class ChooseModeDialog extends StatelessWidget {
  final String folderName;
  final String folderId;
  final Color headerColor;
  final List<Map<String, String>> questions;

  const ChooseModeDialog({
    super.key,
    required this.folderName,
    required this.folderId,
    required this.headerColor,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a Quiz Mode',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionIdentificationModeModelWidget(
                      folderName: folderName,
                      folderId: folderId,
                      headerColor: headerColor,
                      questions: questions,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                fixedSize: const Size(250, 50),
              ),
              child: const Text(
                'Identification Mode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionMultipleOptionModeModelWidget(
                      folderName: folderName,
                      folderId: folderId,
                      headerColor: headerColor,
                      questions: questions,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                fixedSize: const Size(250, 50),
              ),
              child: const Text(
                'Multiple Option Mode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
                fixedSize: const Size(200, 50),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PressStart2P',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
