import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/gemini_manager.dart';
import 'package:food_traker/src/backend/meal_data.dart';
import 'package:food_traker/src/dashboard/chatbot/chat_controller.dart';
import 'package:food_traker/src/dashboard/chatbot/standard_bubble.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key, required this.controller, this.mealData});
  final ChatController controller;

  /// If the user is into a meal screen (for adding a new meal or view an existing one)
  /// this variable contains all the useful data about the meal
  final MealData? mealData;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _messageController = TextEditingController();
  ValueNotifier<bool?> geminiApiKeyPresent = ValueNotifier<bool?>(null);
  Future<void> checkApiKey() async {
    geminiApiKeyPresent.value = await geminiManager.apiKeyConfigured();
  }

  @override
  void initState() {
    checkApiKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.controller.clear();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
          animation: geminiApiKeyPresent,
          builder: (context, snapshot) {
            if (geminiApiKeyPresent.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (geminiApiKeyPresent.value == false) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'Gemini API key is not configured.\nPlease configure it in the settings.'),
              ));
            }
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                                animation: widget.controller,
                                builder: (context, snapshot) {
                                  if (widget.controller.messages.isEmpty) {
                                    return const Center(
                                        child: Text(
                                            'No messages yet.\nPlease send a message to start the conversation.',
                                            textAlign: TextAlign.center));
                                  }
                                  return SingleChildScrollView(
                                    controller:
                                        widget.controller.scrollController,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          widget.controller.messages.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: StandardBubble(
                                            index: index,
                                            controller: widget.controller,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                          ),
                          ValueListenableBuilder(
                            valueListenable: widget.controller.isAiWriting,
                            builder: (context, value, child) {
                              if (value == false) {
                                return const SizedBox();
                              }
                              return const Text('AI is writing...');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () async {
                          String message = _messageController.text;
                          _messageController.clear();
                          await geminiManager.sendMessage(message,
                              mealData: widget.mealData);
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
