class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});

  factory Message.fromJson(dynamic json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
      };
}
