import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/washer_model.dart';

class ManualViewerPage extends StatefulWidget {
  const ManualViewerPage({super.key});

  @override
  State<ManualViewerPage> createState() => _ManualViewerPageState();
}

class _ManualViewerPageState extends State<ManualViewerPage> {
  WasherModel? _myWasher;
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용 설명서'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myWasher == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '내 세탁기가 설정되지 않았습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('뒤로 가기'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 세탁기 정보 헤더
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myWasher!.washerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '기종: ${_myWasher!.washerCode}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                // PDF 뷰어 영역 (추후 구현)
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PDF 뷰어 영역',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '설명서: ${_myWasher!.manualPath}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
