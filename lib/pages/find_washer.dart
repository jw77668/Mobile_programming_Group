
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/washer_model.dart';
import '../services/washer_service.dart';

class FindWasherPage extends StatefulWidget {
  const FindWasherPage({super.key});

  @override
  State<FindWasherPage> createState() => _FindWasherPageState();
}

class _FindWasherPageState extends State<FindWasherPage> {
  final TextEditingController _searchController = TextEditingController();
  List<WasherModel> _washers = [];
  List<WasherModel> _filteredWashers = [];

  @override
  void initState() {
    super.initState();
    _washers = WasherModel.getDefaultWashers();
    _filteredWashers = _washers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWashers(String query) {
    setState(() {
      _filteredWashers = query.isEmpty
          ? _washers
          : _washers.where((washer) {
              return washer.washerName.toLowerCase().contains(query.toLowerCase()) ||
                  washer.washerCode.toLowerCase().contains(query.toLowerCase());
            }).toList();
    });
  }

  Future<void> _setMyWasher(WasherModel washer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('내 세탁기로 설정'),
        content: Text('${washer.washerName}을(를) 내 세탁기로 설정하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('예')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<WasherService>(context, listen: false).updateWasher(washer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${washer.washerName}이(가) 내 세탁기로 설정되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 세탁기 설정하기'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMyWasherCard(context), // 현재 등록된 세탁기 카드
            TextField(
              controller: _searchController,
              onChanged: _filterWashers,
              decoration: InputDecoration(
                hintText: '세탁기 모델명 또는 코드로 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('전체 모델', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredWashers.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            // ✅ 버튼 전체 비율: 가로:세로 = 2:3
                            childAspectRatio: 2 / 3,
                          ),
                      itemCount: _filteredWashers.length,
                      itemBuilder: (context, index) {
                        final washer = _filteredWashers[index];
                        return WasherButton(
                          washer: washer,
                          onTap: () => _setMyWasher(washer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyWasherCard(BuildContext context) {
    return Consumer<WasherService>(
      builder: (context, washerService, child) {
        final currentWasher = washerService.currentWasher;
        if (currentWasher == null) {
          return const SizedBox.shrink();
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('현재 내 세탁기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(currentWasher.imagePath, width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_laundry_service, size: 60, color: Colors.grey)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(currentWasher.washerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(currentWasher.washerCode, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                      tooltip: '내 세탁기에서 삭제',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('삭제 확인'),
                            content: Text('${currentWasher.washerName}을(를) 내 세탁기에서 삭제하시겠습니까?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await washerService.updateWasher(null);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('내 세탁기 정보가 삭제되었습니다.'), backgroundColor: Colors.red));
                          }
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WasherButton extends StatelessWidget {
  final WasherModel washer;
  final VoidCallback onTap;

  const WasherButton({super.key, required this.washer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ 상단 2/3: 이미지 영역
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  washer.imagePath,
                  // ✅ 빈 부분 없이 꽉 차게
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.local_laundry_service,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            // ✅ 하단 1/3: 텍스트 영역 (이름 + 코드)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      washer.washerName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      washer.washerCode,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
