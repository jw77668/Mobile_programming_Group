import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/washer_service.dart';
import 'find_washer.dart';
import 'manual_viewer_page.dart';
import '../models/washer_model.dart';
import 'chatbot_page.dart';
import 'notes_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // SharedPreferences 대신 Provider를 사용하므로 로컬 상태 및 초기화 로직이 필요 없습니다.

  Future<void> _navigateToFindWasher() async {
    // 페이지 이동만 하고 결과를 기다릴 필요가 없습니다.
    // FindWasherPage에서 WasherService의 상태를 직접 업데이트합니다.
    print("Navigating to FindWasherPage...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FindWasherPage()),
    );
  }

  void _navigateToNoteList() {
    print("Navigating to NoteListPage...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<WasherService>를 사용하여 현재 세탁기 정보를 가져옵니다.
    // Consumer 또는 Provider.of(context)를 사용하면 서비스의 데이터가 변경될 때마다
    // 이 위젯이 자동으로 다시 빌드됩니다.
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
            _buildSearchCard(myWasher), // 현재 세탁기 정보를 전달
            const SizedBox(height: 24),
            _buildSectionHeader(context, '내 제품 목록'),
            const SizedBox(height: 12),
            _buildProductList(myWasher), // 현재 세탁기 정보를 전달
            const SizedBox(height: 24),
            _buildSectionHeader(context, '자주 묻는 질문'),
            const SizedBox(height: 12),
            _buildFaqChips(),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '최근 해결 기록'),
            const SizedBox(height: 12),
            _buildRecentHistory(),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '내 메모'),
            const SizedBox(height: 12),
            _buildMemoSection(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMemoSection() {
    return InkWell(
      onTap: _navigateToNoteList,
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
            leading: Icon(
              Icons.note_alt,
              color: Colors.blueAccent,
              size: 28,
            ),
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

  Widget _buildSearchCard(WasherModel? myWasher) {
    return InkWell(
      onTap: () {
        if (myWasher != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              // ChatbotPage는 이제 Provider를 통해 세탁기 정보를 얻으므로 파라미터가 필요 없습니다.
              builder: (context) => const ChatbotPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('먼저 내 제품을 등록해주세요.')),
          );
        }
      },
      child: Card(
        elevation: 0,
        color: const Color(0xFF1F222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            enabled: false,
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
        if (title == '내 제품 목록')
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 16,
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              onPressed: _navigateToFindWasher,
            ),
          ),
      ],
    );
  }

  Widget _buildProductList(WasherModel? myWasher) {
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
        children: [_buildProductCard(myWasher)],
      ),
    );
  }

  Widget _buildProductCard(WasherModel washer) {
    return InkWell(
      onTap: () {
        // ManualViewerPage도 Provider를 통해 세탁기 정보를 얻으므로 파라미터가 필요 없습니다.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManualViewerPage()),
        );
      },
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

  Widget _buildFaqChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        _buildFaqChip('필터 청소하기'),
        _buildFaqChip('소음이 심해요'),
        _buildFaqChip('냄새가 나요'),
        _buildFaqChip('전원이 안 켜져요'),
      ],
    );
  }

  Widget _buildFaqChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          ListTile(title: const Text('냉장고 문 닫힘 문제'), onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(title: const Text('세탁기 탈수 안됨'), onTap: () {}),
        ],
      ),
    );
  }
}
