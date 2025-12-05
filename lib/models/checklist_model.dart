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

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'],
        title: json['title'],
        period: json['period'],
        isDone: json['isDone'],
        reminder: json['reminder'] != null
            ? DateTime.parse(json['reminder'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'period': period,
        'isDone': isDone,
        'reminder': reminder?.toIso8601String(),
      };
}
