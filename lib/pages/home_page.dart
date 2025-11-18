import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  WasherModel? _myWasher;

  @override
  void initState() {
    super.initState();
    _loadMyWasher();
  }

  Future<void> _loadMyWasher() async {
    final prefs = await SharedPreferences.getInstance();
    final washerCode = prefs.getString('my_washer_code');

    if (washerCode != null) {
      final washers = WasherModel.getDefaultWashers();
      setState(() {
        _myWasher = washers.firstWhere(
          (w) => w.washerCode == washerCode,
          orElse: () => washers.first,
        );
      });
    }
  }

  Future<void> _navigateToFindWasher() async {
    // 버튼 클릭 시 로그 확인을 위한 print문 추가
    print("Navigating to FindWasherPage...");
    final result = await Navigator.push<WasherModel>(
      context,
      MaterialPageRoute(builder: (context) => const FindWasherPage()),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('my_washer_code', result.washerCode);
      setState(() {
        _myWasher = result;
      });
    }
  }
  //메모장
  void _navigateToNoteList() {
    print("Navigating to NoteListPage...");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            _buildSearchCard(),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '내 제품 목록'),
            const SizedBox(height: 12),
            _buildProductList(),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '자주 묻는 질문'),
            const SizedBox(height: 12),
            _buildFaqChips(),
            const SizedBox(height: 24),
            _buildSectionHeader(context, '최근 해결 기록'),
            const SizedBox(height: 12),
            _buildRecentHistory(),
            //내 메모 블록 추가
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
  //내 메모 섹션
  Widget _buildMemoSection() {
    return InkWell(
      onTap: _navigateToNoteList, // 메모 페이지 이동 함수 호출
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              Icons.note_alt,
              color: Colors.blueAccent, // 기존 디자인의 아이콘 색상 활용
              size: 28,
            ),
            title: Text(
              '메모 리스트', // 메모장 리스트로 이동함을 명확히 표시
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

  Widget _buildSearchCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotPage()),
        );
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

  Widget _buildProductList() {
    if (_myWasher == null) {
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
        children: [_buildProductCard(_myWasher!)],
      ),
    );
  }

  Widget _buildProductCard(WasherModel washer) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManualViewerPage()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
