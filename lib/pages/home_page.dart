
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Guide', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1F222A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: const Padding(
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
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (title == '내 제품 목록')
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 16,
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              onPressed: () {},
            ),
          ),
      ],
    );
  }

  Widget _buildProductList() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildProductCard('LG 트롬 세탁기'),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                // TODO: Replace with actual image
                child: const Center(child: Icon(Icons.local_laundry_service, size: 40, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
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
          ListTile(
            title: const Text('냉장고 문 닫힘 문제'),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: const Text('세탁기 탈수 안됨'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
