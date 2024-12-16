import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_traker/src/dashboard/chatbot/message.dart';

class ChatController extends ChangeNotifier {
  List<Message> messages = [];
  ValueNotifier<bool> isAiWriting = ValueNotifier(false);

  final ScrollController scrollController = ScrollController();

  void scrollEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void addMessage(Message message) {
    messages.add(message);
    notifyListeners();
  }

  bool get isEmpty => messages.isEmpty;

  void addAiMessage(String text, {String? tooltip}) {
    addMessage(Message(
      senderType: SenderType.assistant,
      text: text,
      tooltip: tooltip,
    ));
  }

  void addUserMessage(String text,
      {String? tooltip, bool answer = false, bool? correct}) {
    addMessage(Message(
      senderType: SenderType.user,
      text: text,
      tooltip: tooltip,
    ));
  }

  void clear() {
    messages.clear();
    notifyListeners();
  }

  Message deleteMessage(int index) {
    final Message removed = messages.removeAt(index);
    notifyListeners();
    return removed;
  }

  void notify() {
    notifyListeners();
  }
}
