import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_guide/models/message.dart';
import 'package:smart_guide/models/solution.dart';
import 'package:smart_guide/providers/chat_provider.dart';
import 'package:uuid/uuid.dart';
import '../services/rag_service.dart';
import '../services/washer_service.dart';
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
  bool _isGeneratingTitle = false; // 제목 생성 중 상태 변수
  ChatState _chatState = ChatState.initializing;
  String? _errorMessage;
  WasherModel? _currentWasher;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // 수정한 메소드 이름으로 변경
      chatProvider.loadInitialChat().then((_) {
        if (widget.solution != null) {
          chatProvider.onSolutionSelected(widget.solution!);
        }
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final washerService = Provider.of<WasherService>(context);
    final newWasher = washerService.currentWasher;
    if (_currentWasher?.washerCode != newWasher?.washerCode) {
      _currentWasher = newWasher;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (_currentWasher == null) {
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
                '안녕하세요! \'${_currentWasher!.washerName}\' 매뉴얼에 대해 무엇이든 물어보세요.',
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
    if (_controller.text.isNotEmpty &&
        !_isBotReplying &&
        _currentWasher != null) {
      final userMessageContent = _controller.text;
      _controller.clear();

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      // sendQuestion 메소드를 사용하도록 변경
      await chatProvider.sendQuestion(userMessageContent, pdfId: _currentWasher!.pdfId);
    }
  }

  void _navigateToPdfPage(int docPage) {
    if (_currentWasher != null) {
      // 문서 페이지 번호를 PDF 뷰어 페이지 번호로 변환
      // 공식: pdf_page = ceil((doc_page + 2) / 2)
      final pdfPage = ((docPage + 2) / 2).ceil();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ManualViewerPage(washer: _currentWasher, initialPage: pdfPage),
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
      _confettiController.play(); // 애니메이션 실행
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('해결 기록이 업데이트되었습니다.'), // 메시지 변경
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final washerName = _currentWasher?.washerName ?? '챗봇';
    final chatProvider = context.watch<ChatProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$washerName 챗봇'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: '새로운 채팅',
            onPressed: () {
              final chatProvider =
                  Provider.of<ChatProvider>(context, listen: false);
              chatProvider.startNewChat();
              _initialize();
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Expanded(child: _buildBody(chatProvider, theme)),
              _buildInputArea(theme),
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

  Widget _buildBody(ChatProvider chatProvider, ThemeData theme) {
    switch (_chatState) {
      case ChatState.initializing:
        return const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          SizedBox(height: 16), Text('챗봇 서버에 연결 중입니다...'),
        ]));
      case ChatState.error:
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
                      onPressed: _initialize,
                      icon: const Icon(Icons.refresh),
                      label: const Text('재시도')),
                ])));
      case ChatState.no_washer:
        return Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  '챗봇을 사용하려면 먼저 제품을 등록해주세요.\n[내 제품] 탭에서 제품을 선택할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: theme.hintColor),
                )));
      case ChatState.ready:
        return ListView.builder(
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

            String displayContent = message.content;
            List<int> pages = List.from(message.pages);

            if (isAssistant) {
              final accuracyIndex = displayContent.indexOf('정확도:');
              final sourceMatch = RegExp(r'출처: 페이지 (.*)').firstMatch(displayContent);

              if (sourceMatch != null) {
                final pageString = sourceMatch.group(1) ?? '';
                final pageNumbers = RegExp(r'\d+')
                    .allMatches(pageString)
                    .map((m) => int.tryParse(m.group(0) ?? ''))
                    .where((p) => p != null)
                    .cast<int>()
                    .toList();
                pages = {...pages, ...pageNumbers}.toList();
              }

              int contentEndIndex = -1;
              if (accuracyIndex != -1) {
                contentEndIndex = accuracyIndex;
              } else if (sourceMatch != null) {
                contentEndIndex = sourceMatch.start;
              }

              if (contentEndIndex != -1) {
                displayContent = displayContent.substring(0, contentEndIndex).trim();
              }
            }

            return Column(
              crossAxisAlignment: isAssistant
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                ChatBubble(message: displayContent, isMe: !isAssistant),
                if (isAssistant && pages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 16.0, bottom: 8.0, top: 8.0),
                    child: Column(
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
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
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
                    ),
                  ),
                if (isAssistant &&
                    isLatestMessage &&
                    previousMessage != null &&
                    previousMessage.role == 'user')
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, bottom: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingTitle
                          ? null
                          : () => _addSolution(message, previousMessage!.content),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
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
                  ),
              ],
            );
          },
        );
    }
  }

  Widget _buildInputArea(ThemeData theme) {
    bool canSend = _chatState == ChatState.ready && !_isBotReplying;
    // isLoading 상태를 chatProvider에서 가져옵니다.
    bool isLoading = context.watch<ChatProvider>().isLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        if (isLoading) // chatProvider의 isLoading 상태를 사용
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
