import 'package:flutter/material.dart';
import '../services/rag_service.dart';
import '../widgets/chat_bubble.dart';

enum ChatState { initializing, ingesting, ready, error }

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final RagService _ragService = RagService();

  bool _isBotReplying = false;
  ChatState _chatState = ChatState.initializing;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _chatState = ChatState.initializing;
      _errorMessage = null;
    });

    try {
      final indexCount = await _ragService.getServerIndexCount();

      if (indexCount == 0) {
        // 서버에 학습된 데이터가 없으면, 학습을 시작
        setState(() => _chatState = ChatState.ingesting);
        await _ragService.ingestLocalManuals();
      }

      // 학습 완료 또는 이미 데이터가 있을 경우, 채팅 준비 완료
      setState(() {
        _chatState = ChatState.ready;
        _messages.clear();
        _messages.insert(0, {
          'message': '안녕하세요! 챗봇이 준비되었습니다. 무엇을 도와드릴까요?',
          'isMe': false,
        });
      });
    } catch (e) {
      setState(() {
        _chatState = ChatState.error;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty && !_isBotReplying) {
      final userMessage = _controller.text;
      _controller.clear();

      setState(() {
        _messages.insert(0, {'message': userMessage, 'isMe': true});
        _isBotReplying = true;
      });

      try {
        final botResponse = await _ragService.search(userMessage);
        setState(() {
          _messages.insert(0, {'message': botResponse, 'isMe': false});
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: ${e.toString().replaceAll("Exception: ", "")}')),
          );
        }
      } finally {
        setState(() {
          _isBotReplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스마트 가이드 챗봇')),
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
        return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16), Text('챗봇 서버에 연결 중입니다...'),
          ]),
        );
      case ChatState.ingesting:
        return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16), Text('서버가 제품 설명서를 학습 중입니다...\n(최초 1회, 몇 분 정도 소요될 수 있습니다)'),
          ]),
        );
      case ChatState.error:
        return Center(
          child: Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(_errorMessage ?? '알 수 없는 오류가 발생했습니다.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _initialize, icon: const Icon(Icons.refresh), label: const Text('재시도')),
          ])),
        );
      case ChatState.ready:
        return ListView.builder(
          reverse: true, padding: const EdgeInsets.all(8.0), itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return ChatBubble(message: message['message'], isMe: message['isMe']);
          },
        );
    }
  }

  Widget _buildInputArea() {
    final bool canSend = _chatState == ChatState.ready && !_isBotReplying;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        if (_isBotReplying) const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8), Text('답변을 생성 중입니다...'),
        ])),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: canSend ? '메시지를 입력하세요...' : '챗봇을 준비 중입니다...', border: const OutlineInputBorder()),
              onSubmitted: canSend ? (_) => _sendMessage() : null,
              enabled: canSend,
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: canSend ? _sendMessage : null),
        ]),
      ]),
    );
  }
}
