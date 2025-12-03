import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/solution.dart';
import '../models/chat_data.dart';
import '../services/chat_data_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatData _chatData;
  final ChatDataService _service = ChatDataService();
  final ScrollController scrollController = ScrollController();

  ChatProvider(ChatData initialData) : _chatData = initialData;

  List<Message> get messages => _chatData.messages;
  List<Solution> get recentSolutions => _chatData.recentSolutions;

  void addMessage(Message msg) {
    _chatData.messages.add(msg);
    notifyListeners();
    _service.saveChatData(_chatData);
  }

  void addSolution(Message msg) {
    final uuid = Uuid().v4();
    final solution = Solution(
      solutionId: uuid,
      messageId: msg.id,
      title: msg.content.length > 20
          ? msg.content.substring(0, 20)
          : msg.content,
      preview: msg.content.length > 60
          ? msg.content.substring(0, 60) + '...'
          : msg.content + '...',
      createdAt: DateTime.now(),
    );
    _chatData.recentSolutions.add(solution);
    notifyListeners();
    _service.saveChatData(_chatData);
  }

  void onSolutionSelected(Solution s) {
    scrollToMessage(s.messageId);
  }

  void scrollToMessage(String messageId) {
    final idx = _chatData.messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      scrollController.animateTo(
        idx * 72.0, // itemExtent or estimated height
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadChatData() async {
    final loaded = await _service.loadChatData();
    if (loaded != null) {
      _chatData = loaded;
      notifyListeners();
    }
  }
}
