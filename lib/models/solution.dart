import 'package:flutter/foundation.dart';

class Solution {
  final String solutionId;
  final String messageId;
  final String title;
  final String preview;
  final DateTime createdAt;

  Solution({
    required this.solutionId,
    required this.messageId,
    required this.title,
    required this.preview,
    required this.createdAt,
  });

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      solutionId: json['solutionId'] as String,
      messageId: json['messageId'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'solutionId': solutionId,
    'messageId': messageId,
    'title': title,
    'preview': preview,
    'createdAt': createdAt.toIso8601String(),
  };
}
