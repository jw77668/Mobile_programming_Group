// note_models.dart 파일 내용

class Note {
  final String id;
  String title;
  String content;
  final DateTime createdDate;
  DateTime modifiedDate;
  final NoteType type;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.modifiedDate,
    this.type = NoteType.Text,
  });

  String get dateString {
    final now = DateTime.now();
    // 당일 생성된 노트는 '오전/오후 HH:MM' 형식으로 표시
    if (createdDate.day == now.day && createdDate.month == now.month && createdDate.year == now.year) {
      final hour = createdDate.hour;
      final minute = createdDate.minute;
      final ampm = hour < 12 ? '오전' : '오후';
      final displayHour = hour > 12 ? hour - 12 : hour;
      return '$ampm $displayHour:${minute.toString().padLeft(2, '0')}';
    }
    // 다른 날짜는 'MM월 DD일'
    return '${createdDate.month}월 ${createdDate.day}일';
  }
}

enum NoteType { Text, HandWriting, Locked }

enum SortOption {
  modifiedDateDesc, // 수정 날짜 내림차순 (기본)
  modifiedDateAsc, // 수정 날짜 오름차순
  titleAsc, // 가나다 오름차순
  titleDesc // 가나다 내림차순
}