import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_data.dart';

class ChatDataService {
  static const String _logStorageKey = 'chat_logs_json';

  /// 내부 헬퍼 함수: 저장된 모든 채팅 로그를 불러옵니다.
  Future<List<ChatData>> _loadAllChats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_logStorageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => ChatData.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 특정 채팅 세션을 전체 로그 리스트에 저장(추가 또는 업데이트)합니다.
  Future<void> saveChatData(ChatData data) async {
    final allChats = await _loadAllChats();
    final index = allChats.indexWhere((chat) => chat.id == data.id);

    if (index != -1) {
      // 기존 채팅 데이터 업데이트
      allChats[index] = data;
    } else {
      // 새로운 채팅 추가
      allChats.add(data);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(allChats.map((chat) => chat.toJson()).toList());
    await prefs.setString(_logStorageKey, jsonString);
  }

  /// 가장 최근의 채팅 세션을 불러옵니다.
  Future<ChatData?> loadLastChat() async {
    final allChats = await _loadAllChats();
    if (allChats.isEmpty) return null;

    // 가장 최근에 시작된 순서로 정렬
    allChats.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allChats.first;
  }

  /// 저장된 모든 채팅 로그를 리스트로 불러옵니다. (최신순 정렬)
  Future<List<ChatData>> loadAllChatLogs() async {
    final allChats = await _loadAllChats();
    // 가장 최근에 시작된 순서로 정렬
    allChats.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allChats;
  }
}
