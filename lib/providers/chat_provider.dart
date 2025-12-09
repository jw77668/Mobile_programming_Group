import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  String? _userEmail;

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
    _userEmail = Hive.box('session').get('current_user');
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
    if (_userEmail == null) return false;
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
    if (_userEmail == null) return;
    final currentSolutions = _chatData.recentSolutions;
    _chatData = ChatData(
      recentSolutions: currentSolutions,
      washerCode: _washerService.currentWasher?.washerCode,
    );
    notifyListeners();
    _chatDataService.saveChatData(_userEmail!, _chatData);
  }

  Future<void> sendQuestion(String question,
      {required String pdfId, Message? replyTo}) async {
    if (question.isEmpty || _userEmail == null) return;

    final userMessage = Message(
      id: const Uuid().v4(),
      role: 'user',
      content: question,
      createdAt: DateTime.now(),
      replyTo: replyTo,
    );
    addMessage(userMessage); // 새 메시지를 대화 목록에 추가

    _setLoading(true);

    try {
      // "물어보기" 시에는 자세한 답변을 받기 위해 shortMode를 false로 설정합니다.
      final bool isShortMode = replyTo == null;

      // AI에게 전달할 대화 기록 (방금 보낸 메시지 제외)
      final history = messages.sublist(1).reversed.toList();

      String questionForRag = question; // 메뉴얼 검색(RAG)에 사용할 질문 (기본값: 현재 질문)

      // "물어보기" 상황일 경우, 메뉴얼 검색에 사용할 질문을 재구성합니다.
      if (replyTo != null) {
        final Message targetMessage = replyTo;

        if (targetMessage.role == 'assistant') {
          // 챗봇의 답변에 "물어보기"를 한 경우:
          // -> 그 답변을 유도했던 '사용자의 원래 질문'을 찾아 검색에 사용합니다.
          final assistantMessageIndex =
          messages.indexWhere((m) => m.id == targetMessage.id);

          if (assistantMessageIndex != -1) {
            // 시간 순으로 이전 대화(리스트에서는 더 높은 인덱스)를 거슬러 올라가 user 질문을 찾습니다.
            for (var i = assistantMessageIndex + 1; i < messages.length; i++) {
              if (messages[i].role == 'user') {
                questionForRag = messages[i].content; // 원래 질문을 RAG 검색에 사용
                break;
              }
            }
          }
        } else {
          // 사용자 본인의 말풍선에 "물어보기"를 한 경우:
          // -> 해당 말풍선의 내용을 검색에 사용합니다.
          questionForRag = targetMessage.content;
        }
      }

      // `search` API 호출
      final ragResponse = await _ragService.search(
        questionForRag,   // 메뉴얼 검색에 최적화된 질문
        pdfId: pdfId,
        previousMessages: history, // AI의 맥락 파악을 위한 전체 대화 기록
        shortMode: isShortMode,
      );

      final botMessage = Message(
          id: const Uuid().v4(),
          role: 'assistant',
          content: ragResponse.answer,
          pages: ragResponse.pages,
          createdAt: DateTime.now(),
          isExpandable: isShortMode);
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
    if (_userEmail == null) return;
    _setLoading(true);

    try {
      final assistantMessageIndex =
          messages.indexWhere((m) => m.id == shortMessage.id);
      if (assistantMessageIndex == -1) {
        throw Exception("Original message not found.");
      }

      Message? userMessage;
      int userMessageIndex = -1;

      for (var i = assistantMessageIndex + 1; i < messages.length; i++) {
        if (messages[i].role == 'user') {
          userMessage = messages[i];
          userMessageIndex = i;
          break;
        }
      }

      if (userMessage == null || userMessageIndex == -1) {
        throw Exception("Original question not found for this message.");
      }
      final originalQuestion = userMessage.content;

      final contextMessages = (userMessageIndex + 1 < messages.length)
          ? messages.sublist(userMessageIndex + 1)
          : <Message>[];

      final ragResponse = await _ragService.search(
        originalQuestion,
        pdfId: pdfId,
        previousMessages: contextMessages.reversed.toList(),
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
          isExpandable: false, // It has been expanded
          isExpanded: true,
          options: shortMessage.options,
          flowId: shortMessage.flowId,
          replyTo: shortMessage.replyTo,
        );
        notifyListeners();
        await _chatDataService.saveChatData(_userEmail!, _chatData);
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
    if (inputText.isEmpty || _userEmail == null) return;

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
    if (_userEmail == null) return;
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
    if (_userEmail == null) return;
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
    if (_userEmail == null) return;
    _chatData.messages.insert(0, msg);
    notifyListeners();
    _chatDataService.saveChatData(_userEmail!, _chatData);
  }

  void clearMessages() {
    if (_userEmail == null) return;
    _chatData.messages.clear();
    notifyListeners();
    _chatDataService.saveChatData(_userEmail!, _chatData);
  }

  Future<void> addSolution({
    required Message answer,
    required String question,
  }) async {
    if (_userEmail == null) return;
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
    await _chatDataService.saveChatData(_userEmail!, _chatData);
  }

  Future<void> onSolutionSelected(Solution s) async {
    if (_userEmail == null) return;
    if (messages.any((m) => m.id == s.messageId)) {
      scrollToMessage(s.messageId);
      return;
    }

    _isSwitchingToHistoricalChat = true;
    try {
      final allLogs = await _chatDataService.loadAllChatLogs(_userEmail!);
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
    if (_userEmail == null) return;
    final lastChat = await _chatDataService.loadLastChat(_userEmail!);
    _chatData = lastChat ?? ChatData(washerCode: _washerService.currentWasher?.washerCode);
    notifyListeners();
  }

  Future<List<ChatData>> loadAllChatLogs() {
    if (_userEmail == null) return Future.value([]);
    return _chatDataService.loadAllChatLogs(_userEmail!);
  }
}
