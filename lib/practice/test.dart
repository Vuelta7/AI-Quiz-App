// AIzaSyDmI_lXDLtPj0IKxhL-49dRhzMS-licJWk

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final user = const types.User(id: 'user');
  final bot = const types.User(id: 'bot');
  final apiKey = 'AIzaSyAj68kDV68B9P_LltYNpiR8oEWT8LL9CWE';

  Future<void> _sendMessage(types.TextMessage message) async {
    setState(() {
      _messages.insert(0, message);
    });

    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message.text}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final botMessageText = responseData['candidates']?[0]['content']?['parts']
              ?[0]['text'] ??
          'I didn’t understand that.';

      final botMessage = types.TextMessage(
        author: bot,
        id: const Uuid().v4(),
        text: botMessageText,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    } else {
      print('Error: ${response.body}');
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: user,
      id: const Uuid().v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    _sendMessage(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chatbot')),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: user,
      ),
    );
  }
}
