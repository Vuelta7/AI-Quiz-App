import 'package:flutter/material.dart';
import 'package:learn_n/model%20widgets/question_model_body_widget.dart';
import 'package:learn_n/model%20widgets/question_model_setting_widget.dart';

class QuestionModelWidget extends StatelessWidget {
  const QuestionModelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Python',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 40,
          ),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          QuestionModelSettingWidget(),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: Column(
            children: [
              Container(
                color: Colors.black,
                height: 4.0,
              ),
              Container(
                color: Colors.black.withOpacity(0.2),
                height: 2.0,
              ),
            ],
          ),
        ),
      ),
      body: const QuestionModelBodyWidget(),
    );
  }
}
