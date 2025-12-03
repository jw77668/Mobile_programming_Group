import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;
  final List<int> pages;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.pages = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pages: (json['pages'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'pages': pages,
  };
}
