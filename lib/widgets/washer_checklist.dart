import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checklist_provider.dart';
import '../models/checklist_model.dart';

class WasherChecklist extends StatefulWidget {
  const WasherChecklist({super.key});

  @override
  State<WasherChecklist> createState() => _WasherChecklistState();
}

class _WasherChecklistState extends State<WasherChecklist> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                const Icon(Icons.checklist),
                const SizedBox(width: 8),
                Text(
                  '세탁기 청소 체크리스트',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedCrossFade(
            firstChild: Container(), // Collapsed state
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Consumer<ChecklistProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChecklistSection(context, '매주', provider.items.where((i) => i.period == '매주').toList()),
                      const Divider(height: 32),
                      _buildChecklistSection(context, '매월', provider.items.where((i) => i.period == '매월').toList()),
                    ],
                  );
                },
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String period) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('새 항목 추가 ($period)'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '항목 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final String title = controller.text;
                if (title.isNotEmpty) {
                  await Provider.of<ChecklistProvider>(context, listen: false)
                      .addItem(title, period);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChecklistSection(BuildContext context, String title, List<ChecklistItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddItemDialog(context, title),
            )
          ],
        ),
        ...items.map((item) => _buildChecklistItem(context, item)).toList(),
      ],
    );
  }

  Widget _buildChecklistItem(BuildContext context, ChecklistItem item) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        await Provider.of<ChecklistProvider>(context, listen: false).toggleItem(item.id);
      },
      child: Row(
        children: [
          Checkbox(value: item.isDone, onChanged: (value) async {
            await Provider.of<ChecklistProvider>(context, listen: false).toggleItem(item.id);
          }),
          Expanded(child: Text(item.title)),
          if (item.period == '매월')
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    item.reminder != null ? Icons.notifications_active : Icons.notifications_on_outlined,
                    color: item.reminder != null ? theme.colorScheme.primary : theme.hintColor,
                  ),
                  onPressed: () async {
                    final provider = Provider.of<ChecklistProvider>(context, listen: false);
                    if (item.reminder != null) {
                      await provider.cancelReminder(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림이 해제되었습니다.')),
                      );
                    } else {
                      await provider.setReminder(item.id, const Duration(days: 30));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('한 달 후에 알림이 설정되었습니다.')),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 14,
                  child: Builder(
                    builder: (context) {
                      if (item.reminder == null) {
                        return const SizedBox.shrink();
                      }
                      final reminderDate = DateUtils.dateOnly(item.reminder!);
                      final today = DateUtils.dateOnly(DateTime.now());
                      final remainingDays = reminderDate.difference(today).inDays;

                      if (remainingDays < 0) {
                        return const SizedBox.shrink();
                      }

                      final dDayText = remainingDays == 0 ? 'D-DAY' : 'D-$remainingDays';

                      return Text(
                        dDayText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () async {
              await Provider.of<ChecklistProvider>(context, listen: false).deleteItem(item.id);
            },
            tooltip: '삭제',
          ),
        ],
      ),
    );
  }
}
