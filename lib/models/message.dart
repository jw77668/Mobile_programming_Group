class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;
  final List<int> pages; // 관련된 페이지 번호
  final List<String> options; // 대화형 선택지
  final String? flowId; // 대화형 흐름 ID

  // "더 알아보기" 기능을 위한 필드
  final bool isExpandable; // 이 메시지가 확장 가능한지 (짧은 답변인지)
  bool isExpanded; // 사용자가 전체 답변을 봤는지

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.pages = const [],
    this.options = const [],
    this.flowId,
    this.isExpandable = false,
    this.isExpanded = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pages: (json['pages'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
      options:
          (json['options'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      flowId: json['flowId'] as String?,
      isExpandable: json['isExpandable'] as bool? ?? false,
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'pages': pages,
      'options': options,
      'flowId': flowId,
      'isExpandable': isExpandable,
      'isExpanded': isExpanded,
    };
  }
}
