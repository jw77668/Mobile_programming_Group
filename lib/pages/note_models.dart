import 'dart:convert';
import 'package:hive/hive.dart';

part 'note_models.g.dart';

// ------------------------------------
// 1. Note Data Model
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
  @HiveField(6)
  bool isStarred;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.modifiedDate,
    this.type = NoteType.Text,
    this.isStarred = false,
  });

  String get plainText {
    if (content.isEmpty) return '';
    try {
      final List<dynamic> jsonData = jsonDecode(content);
      final buffer = StringBuffer();
      for (var item in jsonData) {
        if (item is Map<String, dynamic> && item.containsKey('insert')) {
          buffer.write(item['insert']);
        }
      }
      return buffer.toString().replaceAll('\n', ' ').trim();
    } catch (e) {
      return content; // Fallback for plain text notes
    }
  }

  String get dateString {
    final now = DateTime.now();
    if (createdDate.year == now.year &&
        createdDate.month == now.month &&
        createdDate.day == now.day) {
      final hour = modifiedDate.hour;
      final minute = modifiedDate.minute;
      final ampm = hour < 12 ? '오전' : '오후';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$ampm $displayHour:${minute.toString().padLeft(2, '0')}';
    }
    return '${modifiedDate.month}월 ${modifiedDate.day}일';
  }

  String get fullDateString {
    final date = '${modifiedDate.year}-${modifiedDate.month.toString().padLeft(2, '0')}-${modifiedDate.day.toString().padLeft(2, '0')}';
    final time = '${modifiedDate.hour.toString().padLeft(2, '0')}:${modifiedDate.minute.toString().padLeft(2, '0')}:${modifiedDate.second.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

// ------------------------------------
// 2. Note Type Enum
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
// 3. Sort Option Enum
// ------------------------------------
enum SortOption {
  modifiedDateDesc,
  modifiedDateAsc,
  titleAsc,
  titleDesc
}
