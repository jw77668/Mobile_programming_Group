import 'package:flutter/material.dart';
import '../models/solution.dart';

class RecentSolutionsSheet extends StatelessWidget {
  final List<Solution> solutions;
  final void Function(Solution) onSelected;
  final bool showCard;
  final bool showTitle;
  final bool showDivider;

  const RecentSolutionsSheet({
    super.key,
    required this.solutions,
    required this.onSelected,
    this.showCard = false,
    this.showTitle = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              '최근 해결 기록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ...solutions.map(
          (s) => Column(
            children: [
              ListTile(
                title: Text(s.title),
                subtitle: Text(s.preview),
                trailing: Text(
                  s.createdAt.toLocal().toString().substring(0, 19),
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () => onSelected(s),
              ),
              if (showDivider) const Divider(),
            ],
          ),
        ),
      ],
    );
    if (showCard) {
      return Card(margin: const EdgeInsets.all(12), child: content);
    } else {
      return SingleChildScrollView(child: content);
    }
  }
}
