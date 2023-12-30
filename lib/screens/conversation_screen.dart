import 'package:chat_ai/models/conversation_model.dart';
import 'package:chat_ai/models/message_model.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConversationScreen extends StatefulWidget {
  const ConversationScreen(
      {Key? key, required this.conversation, required this.index})
      : super(key: key);

  final Conversation conversation;
  final int index;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.conversation.messages);
    _loadMessages();
    // chatGPT = OpenAI.instance.build(
    //     token: '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',
    //     baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 2)),enableLog: true,
    // );
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson =
        prefs.getString('messages_${widget.conversation.id}');

    if (messagesJson != null && messagesJson.isNotEmpty) {
      List<dynamic> messagesData = jsonDecode(messagesJson);
      setState(() {
        messages = messagesData.map((data) => Message.fromJson(data)).toList();
      });
    }
  }

  Future<void> _saveConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String conversationsJson = jsonEncode(
      widget.conversation.toJson(),
    );
    await prefs.setString('conversations', conversationsJson);

    String messagesJson =
        jsonEncode(messages.map((message) => message.toJson()).toList());
    await prefs.setString('messages_${widget.conversation.id}', messagesJson);
  }

  Future<void> _sendMessageToAI(String message) async {
    Message userMessage = Message(text: message, isUser: true);

    setState(() {
      widget.conversation.messages.add(userMessage);
      messages = List.from(widget.conversation.messages);
    });

    try {
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization':
              'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages
              .map((message) => {
                    'role': message.isUser ? 'user' : 'assistant',
                    'content': message.text,
                  })
              .toList(),
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String aiResponse = responseData['choices'][0]['message']['content'];

        _saveConversations();

        setState(() {
          widget.conversation.messages
              .add(Message(text: aiResponse, isUser: false));
          messages = List.from(widget.conversation.messages);
        });

        _messageController.clear();
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error calling API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thread ${widget.index + 1}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  final message = messages[index];
                  return ListTile(
                    title: Text(
                      message.text,
                      textAlign:
                          message.isUser ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color: message.isUser ? Colors.blue : Colors.black,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: message.isUser ? 20.0 : 8.0,
                    ),
                    trailing: message.isUser ? const Icon(Icons.person) : null,
                    leading:
                        message.isUser ? null : const Icon(Icons.android), //
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Typing...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    await _sendMessageToAI(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
