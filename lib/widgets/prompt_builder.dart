import 'package:flutter/material.dart';

class PromptBuilder extends StatelessWidget {
  const PromptBuilder({
    super.key,
    required List<ChatMessage> messages,
  }) : _messages = messages;

  final List<ChatMessage> _messages;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _messages[index];
      },
    ));
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.text,
    required this.sender,
  });

  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5).copyWith(
            left: sender == "user" ? 10 : 30,
            right: sender == "user" ? 30 : 10),
        padding: const EdgeInsets.all(8),
        decoration: sender == "user"
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(255, 7, 38, 56)),
        child: Text(
          text.trim(),
          style: TextStyle(
              color: sender == "user"
                  ? const Color.fromARGB(255, 7, 38, 56)
                  : Colors.white,
              fontWeight:
                  sender == "user" ? FontWeight.bold : FontWeight.normal),
        ));
  }
}
