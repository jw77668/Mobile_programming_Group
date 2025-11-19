// 파일 경로: lib/pages/note_models.dart

import 'package:hive/hive.dart';

part 'note_models.g.dart';

// ------------------------------------
// 1. 모델 정의 (Note Data Structure)
// ------------------------------------
@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String content;
  @HiveField(3)
  final DateTime createdDate;
  @HiveField(4)
  DateTime modifiedDate;
  @HiveField(5)
  final NoteType type;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.modifiedDate,
    this.type = NoteType.Text,
  });

  // 날짜/시간 포맷을 위한 Getter
  String get dateString {
    final now = DateTime.now();
    // 오늘 작성된 메모는 시간으로 표시
    if (createdDate.year == now.year &&
        createdDate.month == now.month &&
        createdDate.day == now.day) {
      final hour = modifiedDate.hour;
      final minute = modifiedDate.minute;
      final ampm = hour < 12 ? '오전' : '오후';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$ampm $displayHour:${minute.toString().padLeft(2, '0')}';
    }
    // 다른 날짜에 작성된 메모는 월/일로 표시
    return '${modifiedDate.month}월 ${modifiedDate.day}일';
  }
}

// ------------------------------------
// 메모 타입 정의 (Hive Enum)
// ------------------------------------
@HiveType(typeId: 1)
enum NoteType {
  @HiveField(0)
  Text,
  @HiveField(1)
  HandWriting,
  @HiveField(2)
  Locked
}

// ------------------------------------
// 정렬 옵션 정의 (UI용 Enum)
// ------------------------------------
enum SortOption {
  modifiedDateDesc, // 수정 날짜 내림차순 (기본)
  modifiedDateAsc, // 수정 날짜 오름차순
  titleAsc, // 가나다 오름차순
  titleDesc // 가나다 내림차순
}
