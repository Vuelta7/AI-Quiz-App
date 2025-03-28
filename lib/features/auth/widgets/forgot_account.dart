import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedQuestion;
  String _answer = '';

  final List<String> securityQuestions = [
    "What is your username?",
    "What is your password?",
    "What is your pet's name?",
    "How many points do you have?",
    "How many hint counts do you have?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a 2 security question:'),
              DropdownButtonFormField<String>(
                value: _selectedQuestion,
                items: securityQuestions.map((String question) {
                  return DropdownMenuItem<String>(
                    value: question,
                    child: Text(question),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuestion = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a question' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Your Answer'),
                onChanged: (value) {
                  setState(() {
                    _answer = value;
                  });
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an answer' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedQuestion,
                items: securityQuestions.map((String question) {
                  return DropdownMenuItem<String>(
                    value: question,
                    child: Text(question),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuestion = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a question' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Your Answer'),
                onChanged: (value) {
                  setState(() {
                    _answer = value;
                  });
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an answer' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //hey gpt can u do this for me
                    // check if the users answer is correct and the answer is matching the user firestore
                    // .collection('users')
                    //     .doc(firebaseUser!.uid)
                    //     .set({
                    //   'username': username,
                    //   'password': password,
                    //   'petName': petname,
                    //   'currencypoints': 0,
                    //   'hints': 0,
                    //   'selectedColor': defaultColorHex,
                    // });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Processing your request...')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
              const Text('Email us at: LearnNCustomerServices@gmail.com.'),
            ],
          ),
        ),
      ),
    );
  }
}
