import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      await _firestore.collection('feedback').add({
        'text': feedback,
      });
      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          width: 170,
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: userColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feedback',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: userColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your feedback here...',
                ),
              ),
              const SizedBox(height: 16),
              buildRetroButton(
                'Submit',
                userColor,
                _submitFeedback,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
