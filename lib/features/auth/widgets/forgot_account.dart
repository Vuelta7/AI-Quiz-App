import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/widgets/retro_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedQuestion1;
  String? _selectedQuestion2;
  String _answer1 = '';
  String _answer2 = '';
  String? username = '';
  String? password = '';
  bool showData = false;

  final List<String> securityQuestions = [
    "What is your username?",
    "What is your password?",
    "What is your pet's name?",
    "How many points do you have?",
    "How many hint counts do you have?",
  ];

  Future<void> _verifyAnswers() async {
    if (_formKey.currentState!.validate()) {
      QuerySnapshot usersQuery =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersQuery.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        Map<String, String> storedAnswers = {
          "What is your username?": userData['username'] ?? '',
          "What is your password?": userData['password'] ?? '',
          "What is your pet's name?": userData['petName'] ?? '',
          "How many points do you have?": userData['currencypoints'].toString(),
          "How many hint counts do you have?": userData['hints'].toString(),
        };

        if (storedAnswers[_selectedQuestion1] == _answer1.trim() &&
            storedAnswers[_selectedQuestion2] == _answer2.trim()) {
          username = 'Username: ${userData['username']}';
          password = 'Password: ${userData['password']}';
          showData = true;
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No matching user found. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          'Forgot Account',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      backgroundColor: Colors.blue[400],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a security question:',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PressStart2P',
                    fontSize: 11,
                  ),
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.blue[600],
                  value: _selectedQuestion1,
                  items: securityQuestions.map((String question) {
                    return DropdownMenuItem<String>(
                      value: question,
                      child: Text(
                        question,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedQuestion1 = value),
                  validator: (value) =>
                      value == null ? 'Please select a question' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PressStart2P',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Your Answer',
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                  onChanged: (value) => setState(() => _answer1 = value),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an answer' : null,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Select another security question:',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PressStart2P',
                    fontSize: 11,
                  ),
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.blue[600],
                  value: _selectedQuestion2,
                  items: securityQuestions.map((String question) {
                    return DropdownMenuItem<String>(
                      value: question,
                      child: Text(
                        question,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedQuestion2 = value),
                  validator: (value) =>
                      value == null ? 'Please select a question' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PressStart2P',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Your Answer',
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                  onChanged: (value) => setState(() => _answer2 = value),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an answer' : null,
                ),
                const SizedBox(height: 20),
                buildRetroButton(
                    'Find My Account', Colors.blue[600]!, _verifyAnswers,
                    textColor: Colors.white),
                if (showData)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(username!),
                      Text(password!),
                      const Text(
                        'if its not your account, try changing the security questions and if you still can\'t find it, please contact support in email: LearnNCustomerServices@gmail.com.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
