import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/washer_model.dart';

// 이제 개발 및 배포 환경 모두 동일한 Cloud Run 서버를 사용하므로,
// URL을 하나의 상수로 통일하여 코드를 단순화합니다.
const String serverUrl = 'https://rag-for-smart-guide-1048693665052.asia-northeast3.run.app';

class RagService {
  final String baseUrl = serverUrl;

  RagService();

  /// 서버의 상태를 확인하고, 현재 인덱싱된 청크의 수를 반환합니다.
  Future<int> getServerIndexCount() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      print('Pinging server at: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['index_count'] ?? 0;
      } else {
        throw Exception('서버가 응답하지 않습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('Health check failed: $e');
      throw Exception('서버에 연결할 수 없습니다. 네트워크 상태나 서버 주소를 확인해주세요.');
    }
  }

  /// 앱에 내장된 모든 PDF 매뉴얼을 서버에 업로드하여 학습시킵니다.
  Future<void> ingestLocalManuals() async {
    print('Starting local manual ingestion...');
    final manuals = WasherModel.getDefaultWashers();

    for (final manual in manuals) {
      final manualPath = manual.manualPath;
      final fileName = manualPath.split('/').last;
      print('Uploading and ingesting $fileName...');

      try {
        final byteData = await rootBundle.load(manualPath);
        final List<int> fileBytes = byteData.buffer.asUint8List();

        final uri = Uri.parse('$baseUrl/ingest_pdf/');
        final request = http.MultipartRequest('POST', uri);
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        );
        request.files.add(multipartFile);

        // PDF 처리 및 임베딩은 시간이 걸릴 수 있으므로 타임아웃을 길게 설정합니다.
        final streamedResponse = await request.send().timeout(const Duration(minutes: 3));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('$fileName ingestion successful: Added ${responseData['added_chunks']} chunks.');
        } else {
          // 서버에서 오류가 발생했음을 알립니다.
          print('Failed to ingest $fileName. Status: ${response.statusCode}, Body: ${response.body}');
          throw Exception('$fileName 학습 중 서버에서 오류가 발생했습니다.');
        }
      } catch (e) {
        print('Error ingesting $fileName: $e');
        throw Exception('$fileName 업로드 또는 학습 중 오류가 발생했습니다.');
      }
    }
    print('All local manuals have been processed.');
  }

  /// 서버에 질문을 보내고 생성된 답변을 받아옵니다.
  Future<String> search(String question, {int topK = 3}) async {
    final uri = Uri.parse('$baseUrl/query/');
    final payload = jsonEncode({'question': question, 'top_k': topK});

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
      return data['answer'] ?? '답변을 받는 데 실패했습니다.';
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 서버가 응답하지 않습니다.');
    } catch (e) {
      print('Search failed: $e');
      rethrow;
    }
  }
}
