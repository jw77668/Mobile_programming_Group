import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_guide/models/message.dart';
import 'package:smart_guide/models/solution.dart';
import 'package:smart_guide/providers/chat_provider.dart';
import 'package:uuid/uuid.dart';
import '../services/rag_service.dart';
import '../widgets/chat_bubble.dart';
import '../models/washer_model.dart';
import 'package:smart_guide/pages/manual_viewer_page.dart';

enum ChatState { initializing, ready, error, no_washer }

class ChatbotPage extends StatefulWidget {
  final Solution? solution;

  const ChatbotPage({super.key, this.solution});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final RagService _ragService = RagService();
  late ConfettiController _confettiController;
  bool _isBotReplying = false;
  bool _isGeneratingTitle = false; 
  ChatState _chatState = ChatState.initializing;
  String? _errorMessage;
  WasherModel? _initializedForWasher;
  double _fontSize = 14.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentWasher = chatProvider.currentChatWasher;
    if (_initializedForWasher?.washerCode != currentWasher?.washerCode) {
      _initializedForWasher = currentWasher;
      _initialize(currentWasher);
    }
  }

  Future<void> _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (widget.solution != null) {
      if (chatProvider.messages.any((m) => m.id == widget.solution!.messageId)) {
        return;
      }
      await chatProvider.onSolutionSelected(widget.solution!);
    } else {
      await chatProvider.loadInitialChat();
    }
    final currentWasher = chatProvider.currentChatWasher;
    _initializedForWasher = currentWasher;
    _initialize(currentWasher);
  }

  Future<void> _initialize(WasherModel? washer) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (washer == null) {
      setState(() => _chatState = ChatState.no_washer);
      return;
    }
    setState(() {
      _chatState = ChatState.initializing;
      _errorMessage = null;
    });
    try {
      await _ragService.getServerIndexCount();
      setState(() {
        _chatState = ChatState.ready;
        if (chatProvider.messages.isEmpty) {
          chatProvider.addMessage(Message(
            id: const Uuid().v4(),
            role: 'assistant',
            content:
                '안녕하세요! \'${washer.washerName}\' 매뉴얼에 대해 무엇이든 물어보세요.',
            createdAt: DateTime.now(),
          ));
        }
      });
    } catch (e) {
      setState(() {
        _chatState = ChatState.error;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  Future<void> _sendMessage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentWasher = chatProvider.currentChatWasher;
    if (_controller.text.isNotEmpty && !_isBotReplying && currentWasher != null) {
      final userMessageContent = _controller.text;
      _controller.clear();

      await chatProvider.sendQuestion(userMessageContent,
          pdfId: currentWasher.pdfId);
    }
  }

  void _navigateToPdfPage(int docPage) {
    final currentWasher = Provider.of<ChatProvider>(context, listen: false).currentChatWasher;
    if (currentWasher != null) {
      final pdfPage = ((docPage + 2) / 2).ceil();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ManualViewerPage(washer: currentWasher, initialPage: pdfPage),
        ),
      );
    }
  }

  void _showFullManual() {
    final currentWasher = Provider.of<ChatProvider>(context, listen: false).currentChatWasher;
    if (currentWasher != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ManualViewerPage(washer: currentWasher, initialPage: 1),
        ),
      );
    }
  }

  Future<void> _addSolution(Message answer, String question) async {
    setState(() => _isGeneratingTitle = true);

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.addSolution(answer: answer, question: question);

    if (mounted) {
      setState(() => _isGeneratingTitle = false);
      _confettiController.play();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('해결 기록이 업데이트되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _runDiagnosis(String inputText) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentWasher = chatProvider.currentChatWasher;
    if (inputText.isEmpty || currentWasher == null) return;

    await chatProvider.runDiagnosis(inputText, pdfId: currentWasher.pdfId);
  }

  void _startFlow(String problem) {
    if (problem.isEmpty) return;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.startFlow(problem);
  }

  void _continueFlow(String flowId, String choice) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.continueFlow(flowId, choice);
  }

  void _expandMessage(Message message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentWasher = chatProvider.currentChatWasher;
    if (currentWasher == null) return;
    chatProvider.expandMessage(message, pdfId: currentWasher.pdfId);
  }

  void _showDiagnosisDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('증상 / 에러코드 진단'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: '고장 증상이나 에러코드를 입력하세요.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _runDiagnosis(textController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('진단하기'),
          ),
        ],
      ),
    );
  }

  void _showFlowStartDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단계별 문제 해결'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: '어떤 문제가 있나요? (예: 전원이 안 켜져요)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _startFlow(textController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }

  void _showExtraFeaturesMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.build_circle_outlined),
            title: const Text('증상/에러코드 진단'),
            onTap: () {
              Navigator.of(context).pop();
              _showDiagnosisDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('매뉴얼 전체 보기'),
            onTap: () {
              Navigator.of(context).pop();
              _showFullManual();
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('단계별 문제 해결'),
            onTap: () {
              Navigator.of(context).pop();
              _showFlowStartDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showZoomTutorialIfFirstTime() async {
    if (!mounted) return;
    final settingsBox = Hive.box('user_settings');
    final sessionBox = Hive.box('session');
    final currentUser = sessionBox.get('current_user');
    if (currentUser == null) return;

    final key = 'zoom_tutorial_shown_$currentUser';
    final hasShown = settingsBox.get(key) ?? false;

    if (!hasShown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('두 번 탭하면 기본 글자 크기로 돌아갑니다.'),
          duration: Duration(seconds: 3),
        ),
      );
      await settingsBox.put(key, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentWasher = chatProvider.currentChatWasher;
    final washerName = currentWasher?.washerName ?? '챗봇';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$washerName 챗봇'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: '새로운 채팅',
            onPressed: () {
              chatProvider.startNewChat();
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Expanded(child: _buildBody(chatProvider, theme, currentWasher)),
              _buildInputArea(theme, currentWasher),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChatProvider chatProvider, ThemeData theme, WasherModel? currentWasher) {
    if (currentWasher == null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '챗봇을 사용하려면 먼저 제품을 등록해주세요.\n[내 제품] 탭에서 제품을 선택할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: theme.hintColor),
              )));
    }

    if (_chatState == ChatState.initializing) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(),
        SizedBox(height: 16), Text('챗봇 서버에 연결 중입니다...'),
      ]));
    } else if (_chatState == ChatState.error) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error, size: 50),
                const SizedBox(height: 16),
                Text(_errorMessage ?? '알 수 없는 오류가 발생했습니다.',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                    onPressed: () => _initialize(currentWasher),
                    icon: const Icon(Icons.refresh),
                    label: const Text('재시도')),
              ])));
    }

    return GestureDetector(
      onScaleStart: (details) {
        setState(() {
          _scale = 1.0;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = details.scale;
        });
      },
      onScaleEnd: (details) {
        setState(() {
          _fontSize = (_fontSize * _scale).clamp(10.0, 30.0);
          _scale = 1.0;
        });
        _showZoomTutorialIfFirstTime();
      },
      onDoubleTap: () {
        setState(() {
          _fontSize = 14.0;
        });
      },
      child: ListView.builder(
        controller: chatProvider.scrollController,
        reverse: true,
        padding: const EdgeInsets.all(8.0),
        itemCount: chatProvider.messages.length,
        itemBuilder: (context, index) {
          final message = chatProvider.messages[index];
          final isAssistant = message.role == 'assistant';
          final isLatestMessage = index == 0;

          Message? previousMessage;
          if (index + 1 < chatProvider.messages.length) {
            previousMessage = chatProvider.messages[index + 1];
          }

          return Column(
            crossAxisAlignment: isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              ChatBubble(message: message.content, isMe: !isAssistant, fontSize: _fontSize * _scale),
              if (isAssistant)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 16.0, bottom: 8.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.pages.isNotEmpty)
                        _buildPageButtons(theme, message.pages),
                      if (message.options.isNotEmpty && message.flowId != null)
                        _buildOptionButtons(message.flowId!, message.options),
                      _buildAssistantButtons(isLatestMessage, message, previousMessage),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPageButtons(ThemeData theme, List<int> pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관련 페이지',
          style: TextStyle(
            fontSize: 12,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: pages
              .map((page) => TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: Icon(
                      Icons.auto_stories_outlined,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    label: Text(
                      'p.$page',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () => _navigateToPdfPage(page),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOptionButtons(String flowId, List<String> options) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: options
          .map((choice) => ElevatedButton(
                onPressed: () => _continueFlow(flowId, choice),
                child: Text(choice),
              ))
          .toList(),
    );
  }

  Widget _buildAssistantButtons(
      bool isLatest, Message message, Message? previousMessage) {
    final showExpandButton = message.isExpandable && !message.isExpanded;
    final showSolvedButton = isLatest &&
        message.flowId == null &&
        previousMessage != null &&
        previousMessage.role == 'user';

    if (!showExpandButton && !showSolvedButton) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (showExpandButton)
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('더 알아보기'),
              onPressed: () => _expandMessage(message),
            ),
          if (showExpandButton && showSolvedButton) const SizedBox(width: 8),
          if (showSolvedButton)
            ElevatedButton.icon(
              onPressed: _isGeneratingTitle
                  ? null
                  : () => _addSolution(message, previousMessage.content),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: _isGeneratingTitle
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white70),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(_isGeneratingTitle ? '저장 중...' : '해결됐어요!'),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, WasherModel? currentWasher) {
    bool canSend = currentWasher != null && !_isBotReplying;
    bool isLoading = context.watch<ChatProvider>().isLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('답변을 생성 중입니다...'),
            ]),
          ),
        Row(children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: canSend ? _showExtraFeaturesMenu : null,
            tooltip: '추가 기능',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: canSend ? '메시지를 입력하세요...' : '챗봇을 준비 중입니다...',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: canSend ? (_) => _sendMessage() : null,
              enabled: canSend,
            ),
          ),
          IconButton(
              icon: const Icon(Icons.send),
              onPressed: canSend ? _sendMessage : null),
        ]),
      ]),
    );
  }
}
