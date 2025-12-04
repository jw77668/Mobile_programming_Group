import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/solution.dart';
import '../models/chat_data.dart';
import '../services/chat_data_service.dart';
import '../services/conversation_summary_service.dart';
import '../services/rag_service.dart';

class ChatProvider extends ChangeNotifier {
  late ChatData _chatData;
  final ChatDataService _chatDataService = ChatDataService();
  final ConversationSummaryService _conversationSummaryService =
      ConversationSummaryService();
  final RagService _ragService = RagService();
  final ScrollController scrollController = ScrollController();

  // ChatProvider 생성 시 초기 데이터가 필요 없도록 변경
  ChatProvider() {
    _chatData = ChatData(); // 우선 빈 데이터로 시작
  }

  List<Message> get messages => _chatData.messages;
  List<Solution> get recentSolutions => _chatData.recentSolutions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 새로운 채팅 세션을 시작합니다.
  void startNewChat() {
    _chatData = ChatData(); // 새로운 ChatData 객체로 교체
    notifyListeners();
  }

  Future<void> sendQuestion(String question, {required String pdfId}) async {
    if (question.isEmpty) return;

    final userMessage = Message(
      id: const Uuid().v4(),
      role: 'user',
      content: question,
      createdAt: DateTime.now(),
    );
    addMessage(userMessage);

    _setLoading(true);

    try {
      // 메시지 순서를 오래된 순 -> 최신 순으로 변경 (타입 오류 수정)
      List<Message> contextMessages = _chatData.messages.reversed.toList();

      if (contextMessages.length > 10) {
        final toSummarize =
            contextMessages.sublist(0, contextMessages.length - 4);
        final summary = await _conversationSummaryService.summarizeHistory(
            messages: toSummarize);

        final recent = contextMessages.sublist(contextMessages.length - 4);
        final summaryMessage = Message(
            id: 'summary',
            role: 'system',
            content: '이전 대화 요약: $summary',
            createdAt: DateTime.now());

        contextMessages = [summaryMessage, ...recent];
      }

      final ragResponse = await _ragService.search(
        question,
        pdfId: pdfId,
        previousMessages: contextMessages,
      );

      final botMessage = Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: ragResponse.answer,
        createdAt: DateTime.now(),
        pages: ragResponse.pages,
      );
      addMessage(botMessage);
    } catch (e) {
      final errorMessage = Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: '오류가 발생했습니다: $e',
        createdAt: DateTime.now(),
      );
      addMessage(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void addMessage(Message msg) {
    _chatData.messages.insert(0, msg);
    notifyListeners();
    _chatDataService.saveChatData(_chatData); // 현재 chatData 저장
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
    final currentMessageIds = _chatData.messages.map((m) => m.id).toSet();
    _chatData.recentSolutions
        .removeWhere((s) => currentMessageIds.contains(s.messageId));

    final title = await _conversationSummaryService.summarizeConversation(
      question: question,
      answer: answer.content,
    );

    final newSolution = Solution(
      solutionId: const Uuid().v4(),
      messageId: answer.id,
      title: title,
      preview: answer.content.length > 60
          ? '${answer.content.substring(0, 60)}...'
          : answer.content,
      createdAt: DateTime.now(),
    );

    _chatData.recentSolutions.insert(0, newSolution);
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

  /// 앱 시작 시 가장 최근 채팅을 불러옵니다.
  Future<void> loadInitialChat() async {
    final lastChat = await _chatDataService.loadLastChat();
    _chatData = lastChat ?? ChatData(); // 마지막 채팅이 없으면 새로 시작
    notifyListeners();
  }

  /// 모든 채팅 로그를 불러옵니다.
  Future<List<ChatData>> loadAllChatLogs() {
    return _chatDataService.loadAllChatLogs();
  }
}
