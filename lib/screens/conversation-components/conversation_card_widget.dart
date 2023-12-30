import 'package:chat_ai/models/conversation_model.dart';
import 'package:flutter/material.dart';
import '../conversation_screen.dart';

class ConversationCard extends StatelessWidget {
  const ConversationCard({Key? key, required this.conversation})
      : super(key: key);

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              index: 0,
              conversation: conversation,
            ),
          ),
        );
      },
    );
  }
}
