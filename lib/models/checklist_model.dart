import 'package:flutter/foundation.dart';

class ChecklistItem {
  final String id;
  final String title;
  final String period;
  bool isDone;
  DateTime? reminder;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.period,
    this.isDone = false,
    this.reminder,
  });
}
