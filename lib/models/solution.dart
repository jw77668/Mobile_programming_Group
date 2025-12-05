import 'package:flutter/foundation.dart';

class Solution {
  final String solutionId;
  final String messageId;
  final String? washerCode; // Add this
  final String title;
  final String preview;
  final DateTime createdAt;

  Solution({
    required this.solutionId,
    required this.messageId,
    this.washerCode, // Add this
    required this.title,
    required this.preview,
    required this.createdAt,
  });

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      solutionId: json['solutionId'] as String,
      messageId: json['messageId'] as String,
      washerCode: json['washerCode'] as String?, // Add this
      title: json['title'] as String,
      preview: json['preview'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'solutionId': solutionId,
    'messageId': messageId,
    'washerCode': washerCode, // Add this
    'title': title,
    'preview': preview,
    'createdAt': createdAt.toIso8601String(),
  };
}
