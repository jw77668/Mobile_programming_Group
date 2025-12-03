import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _openRouterApiKey = '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';
const String _openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';

class TitleGenerationService {
  Future<String> generateTitle({
    required String question,
    required String answer,
  }) async {
    if (_openRouterApiKey != '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') {
      // 개발 편의를 위해 API 키가 없을 경우, 임시 제목을 반환합니다.
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
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        String title = data['choices'][0]['message']['content'] ?? '';
        // 불필요한 따옴표나 특수문자 제거
        title = title.replaceAll(RegExp(r'["*`]'), '').trim();
        return title.isNotEmpty ? title : '제목 생성 실패';
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('API 요청 시간 초과');
    } catch (e) {
      return '제목 생성 중 오류 발생'; // 오류 발생 시 사용자에게 표시될 제목
    }
  }
}
