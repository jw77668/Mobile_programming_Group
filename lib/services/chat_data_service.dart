import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_data.dart';

class ChatDataService {
  static const String _boxName = 'chat_logs';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  /// 내부 헬퍼 함수: 특정 사용자의 모든 채팅 로그를 불러옵니다.
  Future<List<ChatData>> _loadAllChats(String userEmail) async {
    final box = await _getBox();
    final jsonString = box.get(userEmail) as String?;
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => ChatData.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 특정 사용자의 채팅 세션을 전체 로그 리스트에 저장(추가 또는 업데이트)합니다.
  Future<void> saveChatData(String userEmail, ChatData data) async {
    final allChats = await _loadAllChats(userEmail);
    final index = allChats.indexWhere((chat) => chat.id == data.id);

    if (index != -1) {
      // 기존 채팅 데이터 업데이트
      allChats[index] = data;
    } else {
      // 새로운 채팅 추가
      allChats.add(data);
    }

    final box = await _getBox();
    final jsonString = jsonEncode(allChats.map((chat) => chat.toJson()).toList());
    await box.put(userEmail, jsonString);
  }

  /// 특정 사용자의 가장 최근 채팅 세션을 불러옵니다.
  Future<ChatData?> loadLastChat(String userEmail) async {
    final allChats = await _loadAllChats(userEmail);
    if (allChats.isEmpty) return null;

    // 가장 최근에 시작된 순서로 정렬
    allChats.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allChats.first;
  }

  /// 특정 사용자의 모든 채팅 로그를 리스트로 불러옵니다. (최신순 정렬)
  Future<List<ChatData>> loadAllChatLogs(String userEmail) async {
    final allChats = await _loadAllChats(userEmail);
    // 가장 최근에 시작된 순서로 정렬
    allChats.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allChats;
  }
}
