import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsHistoryScreen extends StatefulWidget {
  const NewsHistoryScreen({super.key});

  @override
  State<NewsHistoryScreen> createState() => _NewsHistoryScreenState();
}

class _NewsHistoryScreenState extends State<NewsHistoryScreen> {
  final String backendIp = '192.168.30.4';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  List<Map<String, dynamic>> newsHistory = [];

  @override
  void initState() {
    super.initState();
    loadNewsHistory();
  }

  Future<void> loadNewsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'anonymous';

    final uri = Uri.parse('http://$backendIp:8000/news-history?username=$username');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      setState(() {
        newsHistory = List<Map<String, dynamic>>.from(decoded['records']);
      });
    } else {
      print('❌ 뉴스 기록 불러오기 실패: ${res.body}');
    }
  }

  void _playTTS(String summary) async {
    if (isPlaying) {
      await _audioPlayer.stop();
      setState(() => isPlaying = false);
      return;
    }

    final uri = Uri.parse('http://$backendIp:8000/tts/synthesize');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': summary}),
    );

    final decoded = jsonDecode(res.body);
    final audioPath = decoded['file_url'];
    if (audioPath != null) {
      final fullUrl = 'http://$backendIp:8000$audioPath';
      await _audioPlayer.play(UrlSource(fullUrl));
      setState(() => isPlaying = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFFE3FFCD),
  appBar: AppBar(
    title: const Text("뉴스 요약"),
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  body: newsHistory.isEmpty
      ? const Center(
          child: Text("저장된 뉴스 기록이 없습니다.",
              style: TextStyle(fontSize: 18)),
        )
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: newsHistory.length + 1, // 🔥 버튼 추가를 위해 +1
          itemBuilder: (context, index) {
            if (index == 0) {
              return Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewsHistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text(
                    "뉴스 기록 보기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'HakgyoansimGeurimilgi',
                    ),
                  ),
                ),
              );
            }

            final item = newsHistory[index - 1]; // ⚠️ index 보정
            final date = item['date'] ?? '날짜 없음';
            final keyword = item['keyword'] ?? '키워드 없음';
            final summary = item['summary'] ?? '요약 없음';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    '"$keyword"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          summary.length > 70
                              ? '${summary.substring(0, 70)}...'
                              : summary,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Image.asset(
                          isPlaying
                              ? 'assets/images/Sound_Off.png'
                              : 'assets/images/Sound_On.png',
                          width: 34,
                          height: 40,
                        ),
                        onPressed: () => _playTTS(summary),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
);

  }
}
