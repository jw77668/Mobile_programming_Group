import 'package:uuid/uuid.dart';
import 'message.dart';
import 'solution.dart';

class ChatData {
  final String id;
  final DateTime startTime;
  final List<Message> messages;
  final List<Solution> recentSolutions;
  final String? washerCode; // 세탁기 코드 추가

  ChatData({
    String? id,
    DateTime? startTime,
    List<Message>? messages,
    List<Solution>? recentSolutions,
    this.washerCode,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        messages = messages ?? [],
        recentSolutions = recentSolutions ?? [];

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      id: json['id'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
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
      washerCode: json['washerCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'messages': messages.map((e) => e.toJson()).toList(),
        'recentSolutions': recentSolutions.map((e) => e.toJson()).toList(),
        'washerCode': washerCode,
      };
}
