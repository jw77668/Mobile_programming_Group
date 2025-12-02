import 'package:flutter/material.dart';
import '../models/washer_model.dart';

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
      if (query.isEmpty) {
        _filteredWashers = _washers;
      } else {
        _filteredWashers = _washers.where((washer) {
          return washer.washerName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              washer.washerCode.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _setMyWasher(WasherModel washer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('내 세탁기로 설정'),
        content: Text('${washer.washerName}을(를) 내 세탁기로 설정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: 실제 저장 로직 구현 (SharedPreferences 등)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${washer.washerName}이(가) 내 세탁기로 설정되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, washer);
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
            // 검색창
            TextField(
              controller: _searchController,
              onChanged: _filterWashers,
              decoration: InputDecoration(
                hintText: '내 세탁기 찾기.....',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            // 세탁기 목록
            Expanded(
              child: _filteredWashers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
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
                        return WasherButton(
                          washer: _filteredWashers[index],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${_filteredWashers[index].washerName} 선택됨',
                                ),
                              ),
                            );
                          },
                          onLongPress: () =>
                              _setMyWasher(_filteredWashers[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 세탁기 버튼 위젯
class WasherButton extends StatelessWidget {
  final WasherModel washer;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const WasherButton({
    super.key,
    required this.washer,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
