import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_data.dart';

class ChatDataService {
  static const String _storageKey = 'chat_data_json';

  Future<void> saveChatData(ChatData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<ChatData?> loadChatData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return null;
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ChatData.fromJson(json);
  }
}
