import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_guide/main.dart';
import '../services/washer_service.dart';
import 'manual_viewer_page.dart';
import '../models/washer_model.dart';
import 'notes_list_page.dart';
import 'FAQ/filter_clean.dart';
import 'FAQ/noise.dart';
import 'FAQ/bad_smell.dart';
import 'FAQ/power_off.dart';
import '../widgets/recent_solutions_home.dart';
import '../providers/chat_provider.dart';
import '../widgets/washer_checklist.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToNoteList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myWasher = Provider.of<WasherService>(context).currentWasher;
    final theme = Theme.of(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(context, myWasher),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '내 제품', myWasher, navProvider),
            const SizedBox(height: 12),
            _buildProductList(context, myWasher),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '자주 묻는 질문', null, navProvider),
            const SizedBox(height: 12),
            _buildFaqChips(context, navProvider),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '최근 해결 기록', null, navProvider),
            const SizedBox(height: 12),
            _buildRecentHistory(context, navProvider),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '할 일', null, navProvider),
            const SizedBox(height: 12),
            const WasherChecklist(),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '메모', null, navProvider),
            const SizedBox(height: 12),
            _buildMemoSection(context),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  Widget _buildMemoSection(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _navigateToNoteList(context),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.note_alt, color: theme.colorScheme.primary, size: 28),
            title: const Text(
              '노트 목록',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: theme.hintColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, WasherModel? myWasher) {
    final theme = Theme.of(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        if (myWasher != null) {
          navProvider.changeTab(2);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('먼저 내 제품을 등록해주세요.')));
        }
      },
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              decoration: InputDecoration(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.search, color: theme.hintColor, size: 20),
                ),
                hintText: '무엇을 도와드릴까요? (예: 전원이 안 켜져요)',
                hintStyle: TextStyle(color: theme.hintColor),
                border: InputBorder.none,
                suffixIcon: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.arrow_forward, color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, WasherModel? myWasher, NavigationProvider navProvider) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (title == '내 제품')
          TextButton(
            onPressed: () => navProvider.changeTab(1),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              '내 세탁기 설정하기',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildProductList(BuildContext context, WasherModel? myWasher) {
    final theme = Theme.of(context);
    if (myWasher == null) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            '아직 내 세탁기가 설정되지 않았습니다',
            style: TextStyle(fontSize: 14, color: theme.hintColor),
          ),
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [_buildProductCard(context, myWasher)],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WasherModel washer) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ManualViewerPage(washer: washer)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    washer.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_laundry_service,
                            size: 40,
                            color: theme.hintColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                washer.washerName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqChips(BuildContext context, NavigationProvider navProvider) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        _buildFaqChip(context, '필터 청소하기', const FilterCleanFAQ(), navProvider),
        _buildFaqChip(context, '소음이 심해요', const NoiseFAQ(), navProvider),
        _buildFaqChip(context, '악취가 나요', const BadSmellFAQ(), navProvider),
        _buildFaqChip(context, '전원이 안 켜져요', const PowerOffFAQ(), navProvider),
      ],
    );
  }

  Widget _buildFaqChip(BuildContext context, String label, Widget page, NavigationProvider navProvider) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      onPressed: () {
        navProvider.showCustomPage(page);
      },
      backgroundColor: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, NavigationProvider navProvider) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return RecentSolutionsHome(
      onSolutionTap: (solution) async {
        await chatProvider.onSolutionSelected(solution);
        navProvider.changeTab(2);
      },
    );
  }
}
