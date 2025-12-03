import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/washer_service.dart';
import 'find_washer.dart';
import 'manual_viewer_page.dart';
import '../models/washer_model.dart';
import 'chatbot_page.dart';
import 'notes_list_page.dart';
import 'FAQ/filter_clean.dart';
import 'FAQ/noise.dart';
import 'FAQ/bad_smell.dart';
import 'FAQ/power_off.dart';
import '../widgets/recent_solutions_home.dart';
import '../providers/chat_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _navigateToFindWasher(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FindWasherPage()),
    );
  }

  void _navigateToNoteList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myWasher = Provider.of<WasherService>(context).currentWasher;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(context, myWasher),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '내 제품'),
            const SizedBox(height: 12),
            _buildProductList(context, myWasher),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '자주 묻는 질문'),
            const SizedBox(height: 12),
            _buildFaqChips(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '최근 해결 기록'),
            const SizedBox(height: 12),
            _buildRecentHistory(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '내 메모'),
            const SizedBox(height: 12),
            _buildMemoSection(context),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMemoSection(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToNoteList(context),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.note_alt, color: Colors.blueAccent, size: 28),
            title: Text(
              '메모 리스트',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, WasherModel? myWasher) {
    return InkWell(
      onTap: () {
        if (myWasher != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotPage()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('먼저 내 제품을 등록해주세요.')));
        }
      },
      child: Card(
        elevation: 0,
        color: const Color(0xFF1F222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const IgnorePointer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.search, color: Colors.white54, size: 20),
                ),
                hintText: '무엇을 도와드릴까요? (예: 전원이 안 켜져요)',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                suffixIcon: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (title == '내 제품')
          TextButton(
            onPressed: () => _navigateToFindWasher(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
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
    if (myWasher == null) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            '아직 내 세탁기가 설정되지 않았습니다',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ManualViewerPage()),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
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
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_laundry_service,
                            size: 40,
                            color: Colors.grey,
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

  Widget _buildFaqChips(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        _buildFaqChip(context, '필터 청소하기', const FilterCleanFAQ()),
        _buildFaqChip(context, '소음이 심해요', const NoiseFAQ()),
        _buildFaqChip(context, '악취가 나요', const BadSmellFAQ()),
        _buildFaqChip(context, '전원이 안 켜져요', const PowerOffFAQ()),
      ],
    );
  }

  Widget _buildFaqChip(BuildContext context, String label, Widget page) {
    return ActionChip(
      label: Text(label),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    return RecentSolutionsHome(
      onSolutionTap: (solution) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatbotPage(solution: solution)),
        );
      },
    );
  }
}
