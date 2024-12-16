import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_traker/src/dashboard/chatbot/chat_controller.dart';
import 'package:food_traker/src/dashboard/chatbot/markdown_render.dart';
import 'package:food_traker/src/dashboard/chatbot/message.dart';

class StandardBubble extends StatefulWidget {
  final int index;
  final ChatController controller;
  final Color? boxColor;
  final bool showSenderIcon;
  const StandardBubble(
      {super.key,
      required this.index,
      required this.controller,
      this.boxColor,
      this.showSenderIcon = true});

  @override
  State<StandardBubble> createState() => _StandardBubbleState();
}

class _StandardBubbleState extends State<StandardBubble> {
  Message get message => widget.controller.messages[widget.index];

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        final RenderObject? overlay =
            Overlay.of(context).context.findRenderObject();
        final Offset position = details.globalPosition;
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromLTWH(position.dx, position.dy, 0, 0),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height),
          ),
          items: [
            PopupMenuItem(
                value: 1,
                child: const Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text("Copia testo"),
                  ],
                ),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: message.text),
                  );
                }),
          ],
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      },
      child: Row(
        key: _key,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: message.senderType == SenderType.user
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.senderType == SenderType.assistant &&
              widget.showSenderIcon)
            Tooltip(
              message: widget.controller.messages[widget.index].tooltip ?? '',
              waitDuration: const Duration(milliseconds: 500),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.computer,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.senderType == SenderType.assistant
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.boxColor ??
                        (message.senderType == SenderType.user
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownRender(
                          data: message.text,
                          textColor: message.senderType == SenderType.user
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.senderType == SenderType.user && widget.showSenderIcon)
            Tooltip(
              message: widget.controller.messages[widget.index].tooltip ?? '',
              waitDuration: const Duration(milliseconds: 500),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
