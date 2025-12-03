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
            title: Text(
              '세탁기 청소 체크리스트',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildChecklistSection(BuildContext context, String title, List<ChecklistItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => _buildChecklistItem(context, item)).toList(),
      ],
    );
  }

  Widget _buildChecklistItem(BuildContext context, ChecklistItem item) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Provider.of<ChecklistProvider>(context, listen: false).toggleItem(item.id);
      },
      child: Row(
        children: [
          Checkbox(value: item.isDone, onChanged: (value) {
            Provider.of<ChecklistProvider>(context, listen: false).toggleItem(item.id);
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
                  onPressed: () {
                    final provider = Provider.of<ChecklistProvider>(context, listen: false);
                    if (item.reminder != null) {
                      provider.cancelReminder(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림이 해제되었습니다.')),
                      );
                    } else {
                      provider.setReminder(item.id, const Duration(days: 30));
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
        ],
      ),
    );
  }
}
