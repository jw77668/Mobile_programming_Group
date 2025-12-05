import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.fontSize = 14.0,
  });

  final String message;
  final bool isMe;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMe ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceVariant;
    final textColor = isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          message,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
    );
  }
}
