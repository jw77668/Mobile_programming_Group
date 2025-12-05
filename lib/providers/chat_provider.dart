import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/solution.dart';
import '../models/chat_data.dart';
import '../models/washer_model.dart';
import '../services/chat_data_service.dart';
import '../services/conversation_summary_service.dart';
import '../services/rag_service.dart';
import '../services/washer_service.dart';

class ChatProvider extends ChangeNotifier {
  late ChatData _chatData;
  final ChatDataService _chatDataService = ChatDataService();
  final ConversationSummaryService _conversationSummaryService =
      ConversationSummaryService();
  final RagService _ragService = RagService();
  final ScrollController scrollController = ScrollController();
  final WasherService _washerService;
  String? _currentWasherCode;
  bool _isSwitchingToHistoricalChat = false;

  WasherModel? get currentChatWasher {
    if (_chatData.washerCode == null) {
      return _washerService.currentWasher;
    }
    try {
      return WasherModel.getDefaultWashers()
          .firstWhere((w) => w.washerCode == _chatData.washerCode);
    } catch (e) {
      return _washerService.currentWasher;
    }
  }

  ChatProvider(this._washerService) {
    _chatData = ChatData(washerCode: _washerService.currentWasher?.washerCode);
    _currentWasherCode = _washerService.currentWasher?.washerCode;
    _washerService.addListener(_onWasherChanged);
  }

  @override
  void dispose() {
    _washerService.removeListener(_onWasherChanged);
    super.dispose();
  }

  void _onWasherChanged() {
    if (_isSwitchingToHistoricalChat) return;
    final newWasherCode = _washerService.currentWasher?.washerCode;
    if (_currentWasherCode != newWasherCode) {
      _currentWasherCode = newWasherCode;
      startNewChat();
    }
  }

  bool hasUnsavedChat() {
    final lastUserMessageIndex = messages.indexWhere((m) => m.role == 'user');
    if (lastUserMessageIndex == -1) {
      return false;
    }

    final lastAssistantMessageIndex =
        messages.indexWhere((m) => m.role == 'assistant' && m.flowId == null);
    if (lastAssistantMessageIndex == -1) {
      return true;
    }

    if (lastUserMessageIndex < lastAssistantMessageIndex) {
      return true;
    }

    final lastAssistantMessage = messages[lastAssistantMessageIndex];
    final isSaved = _chatData.recentSolutions
        .any((s) => s.messageId == lastAssistantMessage.id);
    return !isSaved;
  }

  List<Message> get messages => _chatData.messages;
  List<Solution> get recentSolutions => _chatData.recentSolutions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void startNewChat() {
    final currentSolutions = _chatData.recentSolutions;
    _chatData = ChatData(
      recentSolutions: currentSolutions,
      washerCode: _washerService.currentWasher?.washerCode,
    );
    notifyListeners();
    _chatDataService.saveChatData(_chatData);
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
      List<Message> contextMessages = _chatData.messages.reversed.toList();

      final ragResponse = await _ragService.search(
        question,
        pdfId: pdfId,
        previousMessages: contextMessages,
        shortMode: true,
      );

      final botMessage = Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: ragResponse.answer,
        pages: ragResponse.pages,
        createdAt: DateTime.now(),
        isExpandable: true,
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

  Future<void> expandMessage(Message shortMessage, {required String pdfId}) async {
    _setLoading(true);

    try {
      final assistantMessageIndex =
          messages.indexWhere((m) => m.id == shortMessage.id);
      if (assistantMessageIndex < 0 ||
          assistantMessageIndex + 1 >= messages.length) {
        throw Exception("Original question not found for this message.");
      }
      final userMessage = messages[assistantMessageIndex + 1];
      if (userMessage.role != 'user') {
        throw Exception(
            "Message before assistant's answer is not a user message.");
      }
      final originalQuestion = userMessage.content;

      final ragResponse = await _ragService.search(
        originalQuestion,
        pdfId: pdfId,
        previousMessages: messages.reversed.toList(),
        shortMode: false,
      );

      final index = messages.indexWhere((m) => m.id == shortMessage.id);
      if (index != -1) {
        messages[index] = Message(
          id: shortMessage.id,
          role: shortMessage.role,
          content: ragResponse.answer,
          pages: ragResponse.pages,
          createdAt: shortMessage.createdAt,
          isExpandable: true,
          isExpanded: true,
          options: shortMessage.options,
          flowId: shortMessage.flowId,
        );
        notifyListeners();
      }
    } catch (e) {
      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: '답변을 확장하는 중 오류가 발생했습니다: $e',
        createdAt: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> runDiagnosis(String inputText, {required String pdfId}) async {
    if (inputText.isEmpty) return;

    addMessage(Message(
      id: const Uuid().v4(),
      role: 'user',
      content: '진단: $inputText',
      createdAt: DateTime.now(),
    ));

    _setLoading(true);
    String diagnosisResult;
    try {
      final isErrorCode = RegExp(r'^[a-zA-Z]+\d+$').hasMatch(inputText);

      if (isErrorCode) {
        diagnosisResult = await _ragService.getErrorCodeDetail(pdfId, inputText);
      } else {
        diagnosisResult = await _ragService.troubleshoot(pdfId, inputText);
      }

      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: diagnosisResult,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: '진단 중 오류가 발생했습니다: $e',
        createdAt: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startFlow(String problem) async {
    final flowId = const Uuid().v4();
    addMessage(Message(
      id: const Uuid().v4(),
      role: 'user',
      content: problem,
      createdAt: DateTime.now(),
      flowId: flowId,
    ));

    _setLoading(true);
    try {
      final response = await _ragService.flowNext(problem: problem);
      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response.question,
        options: response.options,
        flowId: flowId,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: '단계별 진단 중 오류가 발생했습니다: $e',
        createdAt: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> continueFlow(String flowId, String choice) async {
    addMessage(Message(
      id: const Uuid().v4(),
      role: 'user',
      content: choice,
      createdAt: DateTime.now(),
      flowId: flowId,
    ));

    _setLoading(true);

    try {
      final history = _chatData.messages.where((m) => m.flowId == flowId).toList();

      final response = await _ragService.flowNext(history: history.reversed.toList());

      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response.question,
        options: response.options,
        flowId: response.finished ? null : flowId,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      addMessage(Message(
        id: const Uuid().v4(),
        role: 'assistant',
        content: '단계별 진단 중 오류가 발생했습니다: $e',
        createdAt: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }

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
    _chatData.recentSolutions.removeWhere((s) => s.messageId == answer.id);

    final title = await _conversationSummaryService.summarizeConversation(
      question: question,
      answer: answer.content,
    );

    final newSolution = Solution(
      solutionId: const Uuid().v4(),
      messageId: answer.id,
      washerCode: _chatData.washerCode,
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

  Future<void> onSolutionSelected(Solution s) async {
    if (messages.any((m) => m.id == s.messageId)) {
      scrollToMessage(s.messageId);
      return;
    }

    _isSwitchingToHistoricalChat = true;
    try {
      final allLogs = await _chatDataService.loadAllChatLogs();
      ChatData? targetLog;
      for (final log in allLogs) {
        if (log.messages.any((m) => m.id == s.messageId)) {
          targetLog = log;
          break;
        }
      }

      if (targetLog != null) {
        final currentSolutions = List<Solution>.from(_chatData.recentSolutions);

        _chatData = targetLog;

        final existingSolutionIds = _chatData.recentSolutions.map((s) => s.solutionId).toSet();
        currentSolutions.retainWhere((s) => !existingSolutionIds.contains(s.solutionId));
        _chatData.recentSolutions.insertAll(0, currentSolutions);

        notifyListeners();

        if (targetLog.washerCode != null) {
          try {
            final targetWasher = WasherModel.getDefaultWashers()
                .firstWhere((w) => w.washerCode == targetLog!.washerCode);
            await _washerService.updateWasher(targetWasher);
          } catch (e) {
            // Washer not found, do nothing
          }
        }

        Future.delayed(const Duration(milliseconds: 50), () {
          scrollToMessage(s.messageId);
        });
      }
    } finally {
      _isSwitchingToHistoricalChat = false;
    }
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
    } else {
      print('메시지 ID를 찾을 수 없음: $messageId');
    }
  }

  Future<void> loadInitialChat() async {
    final lastChat = await _chatDataService.loadLastChat();
    _chatData = lastChat ?? ChatData();
    notifyListeners();
  }

  Future<List<ChatData>> loadAllChatLogs() {
    return _chatDataService.loadAllChatLogs();
  }
}
