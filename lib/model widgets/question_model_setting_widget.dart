import 'package:flutter/material.dart';

class QuestionModelSettingWidget extends StatelessWidget {
  const QuestionModelSettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, size: 30),
      color: Colors.black,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    width: 3,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 5),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quiz Setting',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "PressStart2P"),
                      ),
                      SizedBox(height: 10),
                      _QuestionModelOptions(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuestionModelOptions extends StatefulWidget {
  const _QuestionModelOptions();

  @override
  State<_QuestionModelOptions> createState() => _QuestionModelOptionsState();
}

class _QuestionModelOptionsState extends State<_QuestionModelOptions> {
  String? _selectedOption = 'Multiple Choice';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Multiple Choice'),
          value: 'Multiple Choice',
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
            });
          },
          activeColor: Colors.black,
        ),
        RadioListTile<String>(
          title: const Text('Typing Only'),
          value: 'Typing Only',
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(
              () {
                _selectedOption = value;
              },
            );
          },
          activeColor: Colors.black,
        ),
      ],
    );
  }
}
