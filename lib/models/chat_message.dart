
class ChatMessage {
  final String message;
  final bool isMe;
  final List<int> pages;

  ChatMessage({required this.message, required this.isMe, this.pages = const []});
}
