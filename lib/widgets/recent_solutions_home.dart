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
    if (solutions.isEmpty) {
      return const SizedBox();
    }
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              '최근 해결 기록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...solutions.map(
            (s) => ListTile(
              title: Text(s.title),
              subtitle: Text(s.preview),
              trailing: Text(
                s.createdAt.toLocal().toString().substring(0, 19),
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => onSolutionTap(s),
            ),
          ),
        ],
      ),
    );
  }
}
