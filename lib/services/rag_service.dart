import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart'; // Message 모델을 가져옵니다.

const String serverUrl = 'https://rag-for-smart-guide-1048693665052.asia-northeast3.run.app';

// 서버 응답을 담을 클래스를 정의합니다. pdf_id 필드를 추가합니다.
class RagResponse {
  final String answer;
  final List<int> pages;
  final String? pdfId;

  RagResponse({required this.answer, required this.pages, this.pdfId});

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    // 서버가 문서 원본 페이지를 제공하므로, 클라이언트에서 페이지 변환을 하지 않습니다.
    final pagesList = (json['pages'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toSet() // 중복된 PDF 페이지 번호를 제거합니다.
            .toList() ??
        [];

    return RagResponse(
      answer: json['answer'] ?? '답변을 받는 데 실패했습니다.',
      pages: pagesList,
      pdfId: json['pdf_id'] as String?, // pdf_id를 파싱합니다.
    );
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

  // 이전 대화 내용을 포함하도록 search 메소드를 수정합니다.
  Future<RagResponse> search(
    String question, {
    required String pdfId,
    int topK = 3,
    List<Message> previousMessages = const [],
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
}
