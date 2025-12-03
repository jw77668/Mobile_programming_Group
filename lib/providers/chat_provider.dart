import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/solution.dart';
import '../models/chat_data.dart';
import '../services/chat_data_service.dart';
import '../services/title_generation_service.dart'; // 새로운 서비스 임포트

class ChatProvider extends ChangeNotifier {
  ChatData _chatData;
  final ChatDataService _chatDataService = ChatDataService();
  final TitleGenerationService _titleGenerationService = TitleGenerationService();
  final ScrollController scrollController = ScrollController();

  ChatProvider(ChatData initialData) : _chatData = initialData;

  List<Message> get messages => _chatData.messages;
  List<Solution> get recentSolutions => _chatData.recentSolutions;

  void addMessage(Message msg) {
    _chatData.messages.insert(0, msg);
    notifyListeners();
    _chatDataService.saveChatData(_chatData);
  }

  void clearMessages() {
    _chatData.messages.clear();
    notifyListeners();
    _chatDataService.saveChatData(_chatData);
  }

  Future<void> addSolution({
    required Message answer,
    required String question,
  }) async {
    if (_chatData.recentSolutions.any((s) => s.messageId == answer.id)) {
      return;
    }

    // LLM을 통해 제목 생성
    final title = await _titleGenerationService.generateTitle(
      question: question,
      answer: answer.content,
    );

    final solution = Solution(
      solutionId: const Uuid().v4(),
      messageId: answer.id,
      title: title,
      preview: answer.content.length > 60
          ? '${answer.content.substring(0, 60)}...'
          : answer.content,
      createdAt: DateTime.now(),
    );

    _chatData.recentSolutions.insert(0, solution); // 최신 기록이 위로 오도록 insert 사용
    notifyListeners();
    await _chatDataService.saveChatData(_chatData);
  }

  void onSolutionSelected(Solution s) {
    scrollToMessage(s.messageId);
  }

  void scrollToMessage(String messageId) {
    final idx = _chatData.messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final double averageItemHeight = 120.0;
      scrollController.animateTo(
        idx * averageItemHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadChatData() async {
    final loaded = await _chatDataService.loadChatData();
    if (loaded != null) {
      _chatData = loaded;
      notifyListeners();
    }
  }
}
