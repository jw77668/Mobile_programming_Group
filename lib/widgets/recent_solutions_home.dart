import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/solution.dart';

class RecentSolutionsHome extends StatelessWidget {
  final void Function(Solution) onSolutionTap;

  const RecentSolutionsHome({Key? key, required this.onSolutionTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final solutions = context.watch<ChatProvider>().recentSolutions;
    final theme = Theme.of(context);

    if (solutions.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Center(
            child: Text(
              '아직 해결된 기록이 없습니다.',
              style: TextStyle(color: theme.hintColor, fontSize: 15),
            ),
          ),
        ),
      );
    }

    final recentSolutionsToShow = solutions.take(5).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: recentSolutionsToShow.map((s) {
            // 날짜와 시간을 원하는 형식으로 변환합니다.
            final formattedDate = '${s.createdAt.year}.${s.createdAt.month.toString().padLeft(2, '0')}.${s.createdAt.day.toString().padLeft(2, '0')} ${s.createdAt.hour.toString().padLeft(2, '0')}:${s.createdAt.minute.toString().padLeft(2, '0')}';

            return ListTile(
              dense: true,
              leading: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
              title: Text(
                s.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                formattedDate,
                style: TextStyle(color: theme.hintColor, fontSize: 13),
              ),
              onTap: () => onSolutionTap(s),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
            );
          }).toList(),
        ),
      ),
    );
  }
}
