import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart'; // Message 모델을 가져옵니다.

const String serverUrl =
    'https://rag-for-smart-guide-1048693665052.asia-northeast3.run.app';

class RagResponse {
  final String answer;
  final List<int> pages;
  final String? pdfId;

  RagResponse({required this.answer, required this.pages, this.pdfId});

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    final pagesList = (json['pages'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toSet()
            .toList() ??
        [];

    return RagResponse(
      answer: json['answer'] ?? '답변을 받는 데 실패했습니다.',
      pages: pagesList,
      pdfId: json['pdf_id'] as String?,
    );
  }
}

// LLM 기반 Flow Engine 응답 모델
class FlowResponse {
  final String question;
  final List<String> options;
  final bool finished;
  final String? note;

  FlowResponse({
    required this.question,
    this.options = const [],
    this.finished = false,
    this.note,
  });

  factory FlowResponse.fromJson(Map<String, dynamic> json) {
    var structured = json['structured'];
    if (structured is String) {
      try {
        structured = jsonDecode(structured);
      } catch (e) {
        structured = null;
      }
    }

    if (structured is Map<String, dynamic>) {
      return FlowResponse(
        question: structured['question'] ?? json['assistant'] ?? '',
        options: (structured['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        finished: structured['finished'] ?? false,
        note: structured['note'] as String?,
      );
    } else {
      // 구조화된 JSON이 없는 경우, assistant 텍스트를 질문으로 사용
      return FlowResponse(question: json['assistant'] ?? '');
    }
  }
}

class RagService {
  final String baseUrl = serverUrl;

  RagService();

  Future<int> getServerIndexCount() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['index_count'] ?? 0;
      } else {
        throw Exception('서버가 응답하지 않습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버에 연결할 수 없습니다. 네트워크 상태나 서버 주소를 확인해주세요.');
    }
  }

  Future<RagResponse> search(
    String question, {
    required String pdfId,
    int topK = 3,
    List<Message> previousMessages = const [],
    bool shortMode = false, // short_mode 파라미터 추가
  }) async {
    final uri = Uri.parse('$baseUrl/query/');

    final List<Map<String, String>> history = previousMessages
        .map((msg) => {
              'source': msg.role,
              'content': msg.content,
            })
        .toList();

    final payload = jsonEncode({
      'question': question,
      'top_k': topK,
      'pdf_id': pdfId,
      'history': history,
      'short_mode': shortMode, // API 요청에 포함
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: payload,
      ).timeout(const Duration(seconds: 30));

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode != 200) {
        throw Exception('검색 실패 (${response.statusCode}): $responseBody');
      }

      final data = jsonDecode(responseBody);
      return RagResponse.fromJson(data);
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> troubleshoot(String pdfId, String symptom) async {
    final uri = Uri.parse('$baseUrl/troubleshoot/');
    final payload = jsonEncode({
      'pdf_id': pdfId,
      'symptom': symptom,
    });

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: payload,
          )
          .timeout(const Duration(seconds: 60));

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode != 200) {
        throw Exception('Troubleshoot 실패 (${response.statusCode}): $responseBody');
      }
      final data = jsonDecode(responseBody);
      return data['diagnosis'] ?? '진단 정보를 받아오지 못했습니다.';
    } on TimeoutException {
      throw Exception('Troubleshoot 요청 시간이 초과되었습니다.');
    } catch (e) {
      rethrow;
    }
  }

  // LLM 기반 Flow Engine 호출
  Future<FlowResponse> flowNext(
      {String? problem, List<Message>? history}) async {
    final uri = Uri.parse('$baseUrl/flow/next');

    Map<String, dynamic> payload = {};
    if (problem != null) {
      payload['problem'] = problem;
    } else if (history != null) {
      payload['history'] = history
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();
    }

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      final responseBody = utf8.decode(response.bodyBytes);
      if (response.statusCode != 200) {
        throw Exception('Flow Engine 실패 (${response.statusCode}): $responseBody');
      }
      final data = jsonDecode(responseBody);
      return FlowResponse.fromJson(data);
    } on TimeoutException {
      throw Exception('Flow Engine 요청 시간이 초과되었습니다.');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getErrorCodeDetail(String pdfId, String errorCode) async {
    final uri = Uri.parse('$baseUrl/error-code/');
    final payload = jsonEncode({
      'pdf_id': pdfId,
      'error_code': errorCode,
    });
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: payload,
          )
          .timeout(const Duration(seconds: 60));

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode != 200) {
        throw Exception('Error Code 실패 (${response.statusCode}): $responseBody');
      }
      final data = jsonDecode(responseBody);
      return data['error_detail'] ?? '에러코드 정보를 받아오지 못했습니다.';
    } on TimeoutException {
      throw Exception('Error Code 요청 시간이 초과되었습니다.');
    } catch (e) {
      rethrow;
    }
  }
}
