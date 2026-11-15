class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final String course;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.course,
    required this.timestamp,
  });

  factory ChatMessage.fromUser({required String text, required String course}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      course: course,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.fromAssistant({required String text, required String course}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      course: course,
      timestamp: DateTime.now(),
    );
  }
}
