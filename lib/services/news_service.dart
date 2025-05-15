import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 사용자가 입력한 자연어 문장을 통해
/// 키워드를 추출하고 관련 뉴스 URL 3개를 찾아
/// 본문을 요약한 결과를 리스트로 반환
Future<List<Map<String, String>>> fetchNewsFromText(String text) async {
  final apiUrl = '${dotenv.env['API_URL']}/search-news-urls/';
  print('📡 요청 URL (뉴스 검색 + 요약): $apiUrl');

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'request_text': text}),
  );

  if (response.statusCode == 200) {
    final decoded = utf8.decode(response.bodyBytes); 
    final List<dynamic> data = jsonDecode(decoded);   // body → decoded

    return data.map<Map<String, String>>((item) => {
      'url': item['url'] ?? '',
      'summary': item['summary'] ?? '',
    }).toList();
  } else {
    throw Exception('뉴스 검색 및 요약 실패: ${response.statusCode}');
  }

}
