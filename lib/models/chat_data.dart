import 'message.dart';
import 'solution.dart';

class ChatData {
  final List<Message> messages;
  final List<Solution> recentSolutions;

  ChatData({required this.messages, required this.recentSolutions});

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentSolutions:
          (json['recentSolutions'] as List<dynamic>?)
              ?.map((e) => Solution.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'messages': messages.map((e) => e.toJson()).toList(),
    'recentSolutions': recentSolutions.map((e) => e.toJson()).toList(),
  };
}
