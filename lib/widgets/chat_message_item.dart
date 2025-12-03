import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatMessageItem extends StatelessWidget {
  final Message message;
  final VoidCallback? onSolution;

  const ChatMessageItem({Key? key, required this.message, this.onSolution})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(message.id),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text(message.role == 'user' ? 'U' : 'A')),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.content),
                Text(
                  message.createdAt.toLocal().toString().substring(0, 19),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (onSolution != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onSolution,
                      child: const Text('해결됨'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
