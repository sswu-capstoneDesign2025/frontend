import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/services/news_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:capstone_story_app/screens/home/news_history_screen.dart';


class NewsScreen extends StatefulWidget {
  final String? inputText;
  final String? summaryText; 

  const NewsScreen({super.key, this.inputText, this.summaryText});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<News> newsList = [];
  String combinedNewsSummary = '';
  bool isLoading = true;
  bool isPlaying = false;

  final String backendIp = '192.168.30.4';

  @override
  void initState() {
    super.initState();
    print("🚀 NewsScreen initState 실행됨");

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
    });

    if (widget.summaryText != null && widget.summaryText!.isNotEmpty) {
      print("📝 전달받은 요약문으로 화면 구성!");
      setState(() {
        combinedNewsSummary = widget.summaryText!;
        isLoading = false;
      });
    } else if (widget.inputText != null) {
      print("🔍 inputText 있음: ${widget.inputText}");
      loadNewsFromAPI();
    } else {
      isLoading = false;
    }
  }


  Future<void> loadNewsFromAPI() async {
    try {
      final result = await fetchNewsFromText(widget.inputText!);
      final summaries = result['summaries'] as List<dynamic>?;

      setState(() {
        newsList = summaries?.map((e) => News(
              title: e['summary'] ?? '제목 없음',
              content: e['summary'] ?? '요약 없음',
              url: e['url'] ?? '',
            )).toList() ?? [];

        combinedNewsSummary = result['combined_summary'] ?? '';
        isLoading = false;
      });

      print("✅ 최종 newsList 길이: ${newsList.length}");
    } catch (e) {
      print('❌ 에러 발생: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleTTS() async {
  if (isPlaying) {
    await _audioPlayer.stop();
    await _audioPlayer.release(); 
    setState(() => isPlaying = false);
  } else {
    try {
      setState(() => isPlaying = true); // 🔒 버튼 비활성화를 위해 미리 설정
      final uri = Uri.parse('http://$backendIp:8000/tts/synthesize');

      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': combinedNewsSummary}),
          )
          .timeout(const Duration(seconds:15)); // ⏱ 타임아웃 추가

      final decoded = jsonDecode(res.body);
      final audioUrlPath = decoded['file_url'];

      if (audioUrlPath != null) {
        final fullUrl = 'http://$backendIp:8000$audioUrlPath';
        await _audioPlayer.stop();
        await _audioPlayer.release();
        await _audioPlayer.seek(Duration.zero); 
        await _audioPlayer.play(UrlSource(fullUrl));
        // 재생 완료 시 감지해서 자동으로 꺼짐 처리됨 (initState에서 listener 있음)
      } else {
        print('❌ TTS URL 없음');
        setState(() => isPlaying = false);
      }
    } catch (e) {
      print('❌ TTS 오류: $e');
      setState(() => isPlaying = false);
    }
  }
}

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OtherUserStoreScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());

    return CustomLayout(
      isHome: false,
      backgroundColor: const Color(0xFFE3FFCD),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (widget.inputText == null || widget.inputText!.isEmpty)
              ? const Center(
                  child: Text(
                    "아직 검색한 뉴스가 없습니다!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 12),
                        child: Text(
                          "말벗이가 알려주는 요약 뉴스",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BaedalJua',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text(
                          today,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontFamily: 'HakgyoansimGeurimilgi',
                          ),
                        ),
                      ),
                      if (widget.inputText != null && widget.inputText!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 4),
                          child: Text(
                            '"${widget.inputText}"',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'HakgyoansimGeurimilgi',
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFBFB),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFFCFBFB),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  combinedNewsSummary.isNotEmpty
                                      ? combinedNewsSummary
                                      : "요약된 뉴스가 없습니다.",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.7,
                                    fontFamily: 'HakgyoansimGeurimilgi',
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Image.asset(
                                isPlaying
                                    ? 'assets/images/Sound_Off.png'
                                    : 'assets/images/Sound_On.png',
                                width: 39,
                                height: 46,
                              ),
                              onPressed: _toggleTTS,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ 뉴스 기록 보기 버튼 추가
                      Center(
                        child: TextButton.icon(
                          onPressed: isPlaying
                              ? null // 🔒 재생 중이면 비활성화
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const NewsHistoryScreen(),
                                    ),
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
                      ),

                    ],
                  ),
                ),
    );
  }

}
