import 'package:chat_ai/models/message_model.dart';

class Conversation {
  final String id;
  final List<Message> messages;

  Conversation({required this.id, required this.messages});

  factory Conversation.fromJson(dynamic json) {
    List<Message> messages = [];

    if (json['messages'] is List) {
      List<dynamic> messagesData = json['messages'];
      messages = messagesData.map((data) => Message.fromJson(data)).toList();
    }

    return Conversation(
      id: json['id'],
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((message) => message.toJson()).toList(),
      };
}
