import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

//새로운 키 필요
const String _openRouterApiKey = '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';
const String _openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';

class ConversationSummaryService {
  // 기존의 제목 생성 메소드
  Future<String> summarizeConversation({
    required String question,
    required String answer,
  }) async {
    if (_openRouterApiKey == 'sk-or-v1-' || question.isEmpty) {
      return '임시 제목: ${question.substring(0, question.length > 10 ? 10 : question.length)}...';
    }

    final uri = Uri.parse(_openRouterApiUrl);
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_openRouterApiKey',
    };
    final body = jsonEncode({
      'model': 'google/gemini-2.0-flash-exp:free',
      'messages': [
        {
          'role': 'system',
          'content':
              '다음 질문과 답변 내용을 바탕으로, 상황을 가장 잘 요약하는 짧은 제목을 한국어로 생성해줘. 제목은 15자 이내여야 하고, 질문 형식이나 불필요한 부연 설명 없이 명사형으로 간결하게 끝나야 해.',
        },
        {
          'role': 'user',
          'content': '질문: $question\n답변: $answer',
        },
      ],
      'max_tokens': 30,
      'temperature': 0.7,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        String title = data['choices'][0]['message']['content'] ?? '';
        title = title.replaceAll(RegExp(r'["*`]'), '').trim();
        return title.isNotEmpty ? title : '제목 생성 실패';
      } else {
        return '임시 제목: ${question.substring(0, question.length > 10 ? 10 : question.length)}...';
      }
    } catch (e) {
      return '임시 제목: ${question.substring(0, question.length > 10 ? 10 : question.length)}...';
    }
  }

  /// 대화 기록을 점진적으로 요약하는 메소드
  Future<String> summarizeHistory({
    required List<Message> messages,
    String? previousSummary,
  }) async {
    if (_openRouterApiKey == 'sk-or-v1-' || messages.isEmpty) {
      return previousSummary ?? ''; // 키가 없거나 메시지가 없으면 이전 요약 또는 빈 문자열 반환
    }

    // 전체 대화 대신 최근 일부만 사용 (예: 마지막 10개)
    const int recentMessageCount = 10;
    final recentMessages = messages.length > recentMessageCount
        ? messages.sublist(messages.length - recentMessageCount)
        : messages;

    final newConversationText =
        recentMessages.map((m) => '${m.role}: ${m.content}').join('\n\n');

    final uri = Uri.parse(_openRouterApiUrl);
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_openRouterApiKey',
    };
    final body = jsonEncode({
      'model': 'google/gemini-2.0-flash-exp:free',
      'messages': [
        {
          'role': 'system',
          'content':
              '다음은 이전 대화 요약과 새로운 대화 내용입니다. 이 두 가지를 합쳐서 전체 대화의 핵심 내용을 담은 새로운 요약본을 한국어로 만들어줘. 새로운 요약은 기존 요약의 맥락을 유지하면서 최신 정보를 반영해야 합니다. 이 요약은 추후 대화의 맥락으로 다시 사용될 것입니다.',
        },
        {
          'role': 'user',
          'content': '이전 요약: ${previousSummary ?? '없음'}\n\n---\n\n새로운 대화:\n$newConversationText',
        },
      ],
      'max_tokens': 250, // 요약을 위해 토큰 수를 적절히 조정
      'temperature': 0.5,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        String summary = data['choices'][0]['message']['content'] ?? '';
        return summary.replaceAll(RegExp(r'["*`]'), '').trim();
      } else {
        // 실패 시 이전 요약을 그대로 반환하여 맥락 유지
        return previousSummary ?? '';
      }
    } catch (e) {
      // 오류 발생 시에도 이전 요약을 반환
      return previousSummary ?? '';
    }
  }
}
