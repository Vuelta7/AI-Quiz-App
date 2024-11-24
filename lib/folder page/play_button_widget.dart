import 'package:flutter/material.dart';
import 'package:learn_n/model%20widgets/question_model_widget.dart';

class PlayButtonWidget extends StatelessWidget {
  const PlayButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the QuestionScreen when the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionModelWidget()),
        );
      },
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.hexagon_rounded,
            size: 100,
            color: Colors.black,
          ),
          Icon(
            Icons.play_arrow,
            size: 50,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
