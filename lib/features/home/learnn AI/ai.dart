import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/learnn_icon.dart';
import 'package:learn_n/core/widgets/learnn_text.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/services/gemini_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text, userColor) async {
    _messageController.clear();

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          ref: ref,
          userColor: userColor,
        ),
      );
      _isTyping = true;
    });

    final aiResponse = await _geminiService.sendMessage(text);

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          text: aiResponse ?? "I'm sorry, I couldn't process that.",
          isUser: false,
          ref: ref,
          userColor: userColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textIconColor = ref.watch(textIconColorProvider);
    final userColor = ref.watch(userColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: LearnNText(
          fontSize: 22,
          text: 'Learn-N AI',
          font: 'PressStart2P',
          color: textIconColor,
          backgroundColor: getShade(userColor, 500),
        ),
        centerTitle: true,
        backgroundColor: userColor,
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: LearnNIcon(
            color: textIconColor,
            size: 40,
            icon: Icons.arrow_back_rounded,
            shadowColor: getShade(userColor, 500),
            offset: const Offset(2, 2),
          ),
        ),
      ),
      backgroundColor: getShade(userColor, 400),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start a conversation with Learn-N AI',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (_, index) {
                      return _messages[_messages.length - 1 - index];
                    },
                  ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(alignment: Alignment.centerLeft, child: Loading()),
            ),
          Container(
            decoration: BoxDecoration(
              color: userColor,
            ),
            child: SafeArea(
              child: _buildTextComposer(userColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer(userColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (text) => _handleSubmitted(text, userColor),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () =>
                _handleSubmitted(_messageController.text, userColor),
            color: userColor,
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final WidgetRef ref;
  final Color userColor;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.ref,
    required this.userColor,
  });

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: userColor,
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      backgroundColor: userColor,
      child: const Icon(
        Icons.person,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: MarkdownBody(
                data: text, // Render text as Markdown
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }
}
