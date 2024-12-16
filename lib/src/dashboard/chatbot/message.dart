enum SenderType {
  user,
  assistant,
  system;

  @override
  String toString() {
    return this == SenderType.user ? 'user' : 'assistant';
  }

  static SenderType fromString(String value) {
    switch (value) {
      case 'user':
        return SenderType.user;
      case 'assistant':
        return SenderType.assistant;
      default:
        throw Exception('Unknown sender type: $value');
    }
  }
}

class Message {
  String text;
  final SenderType senderType;
  final String? tooltip;
  Message({
    required this.text,
    required this.senderType,
    this.tooltip,
  });

  static Message fromJson(Map<String, dynamic> data) {
    assert(data['content'] != null, "The content field is required.");
    assert(data['role'] != null, "The role field is required.");
    return Message(
      text: data['content'],
      senderType: SenderType.fromString(data['role']),
    );
  }
}
