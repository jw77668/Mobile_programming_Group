
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_guide/models/chat_message.dart';
import '../services/rag_service.dart';
import '../services/washer_service.dart';
import '../widgets/chat_bubble.dart';
import '../models/washer_model.dart';
import 'package:smart_guide/pages/manual_viewer_page.dart';

enum ChatState { initializing, ready, error, no_washer }

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final RagService _ragService = RagService();

  bool _isBotReplying = false;
  ChatState _chatState = ChatState.initializing;
  String? _errorMessage;
  WasherModel? _currentWasher;

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
        _messages.clear();
        _messages.insert(0, ChatMessage(
          message: '안녕하세요! \'${_currentWasher!.washerName}\' 매뉴얼에 대해 무엇이든 물어보세요.',
          isMe: false,
        ));
      });
    } catch (e) {
      setState(() {
        _chatState = ChatState.error;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty && !_isBotReplying && _currentWasher != null) {
      final userMessage = _controller.text;
      _controller.clear();

      setState(() {
        _messages.insert(0, ChatMessage(message: userMessage, isMe: true));
        _isBotReplying = true;
      });

      try {
        final ragResponse = await _ragService.search(
          userMessage,
          pdfId: _currentWasher!.washerCode,
        );
        String botMessage = ragResponse.answer;
        setState(() {
          _messages.insert(0, ChatMessage(message: botMessage, isMe: false, pages: ragResponse.pages));
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: ${e.toString().replaceAll("Exception: ", "")}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isBotReplying = false);
        }
      }
    }
  }

  void _navigateToPdfPage(int page) {
    if (_currentWasher != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManualViewerPage(washer: _currentWasher, initialPage: page),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final washerName = _currentWasher?.washerName ?? '챗봇';
    return Scaffold(
      appBar: AppBar(title: Text('$washerName 챗봇')),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_chatState) {
      case ChatState.initializing:
        return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          SizedBox(height: 16), Text('챗봇 서버에 연결 중입니다...'),
        ]));
      case ChatState.error:
        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(_errorMessage ?? '알 수 없는 오류가 발생했습니다.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: _initialize, icon: const Icon(Icons.refresh), label: const Text('재시도')),
        ])));
      case ChatState.no_washer:
        return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 32.0), child: Text(
          '챗봇을 사용하려면 먼저 제품을 등록해주세요.\n[내 제품] 탭에서 제품을 선택할 수 있습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )));
      case ChatState.ready:
        return ListView.builder(
          reverse: true, padding: const EdgeInsets.all(8.0), itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ChatBubble(message: message.message, isMe: message.isMe),
              if (!message.isMe && message.pages.isNotEmpty)
                Padding(padding: const EdgeInsets.only(left: 60.0, right: 16.0, bottom: 8.0, top: 4.0), child: Wrap(spacing: 8.0, runSpacing: 4.0, children: message.pages.map((page) => ActionChip(
                  avatar: Icon(Icons.find_in_page_outlined, size: 18, color: Colors.blue.shade700),
                  label: Text('p. $page'),
                  labelStyle: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  onPressed: () => _navigateToPdfPage(page),
                )).toList())),
            ]);
          },
        );
    }
  }

  Widget _buildInputArea() {
    bool canSend = _chatState == ChatState.ready && !_isBotReplying;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        if (_isBotReplying) const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8), Text('답변을 생성 중입니다...'),
        ])),
        Row(children: [
          Expanded(child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: canSend ? '메시지를 입력하세요...' : '챗봇을 준비 중입니다...', border: const OutlineInputBorder()),
            onSubmitted: canSend ? (_) => _sendMessage() : null,
            enabled: canSend,
          )),
          IconButton(icon: const Icon(Icons.send), onPressed: canSend ? _sendMessage : null),
        ]),
      ]),
    );
  }
}
