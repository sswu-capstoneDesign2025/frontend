// ✅ [1] NewsScreen - 뉴스 탭에서 홈/수다로 이동 기능 추가

import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/services/news_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsScreen extends StatefulWidget {
  final String? inputText;

  const NewsScreen({super.key, this.inputText});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<News> newsList = [];
  String combinedNewsSummary = '';
  bool isLoading = true;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    print("🚀 NewsScreen initState 실행됨");

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });

    if (widget.inputText != null) {
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
      setState(() => isPlaying = false);
    } else {
      try {
        final uri = Uri.parse('http://localhost:8000/tts/synthesize');
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': combinedNewsSummary}),
        );
        final decoded = jsonDecode(res.body);
        final audioUrlPath = decoded['file_url']; // ✅ 여기 수정됨

        if (audioUrlPath != null) {
          final fullUrl = 'http://localhost:8000$audioUrlPath';
          await _audioPlayer.setUrl(fullUrl);
          await _audioPlayer.play();
          setState(() => isPlaying = true);
        } else {
          print('❌ TTS URL 없음');
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
    return CustomLayout(
      isHome: false,
      backgroundColor: const Color(0xFFE3FFCD),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 12),
                    child: Text(
                      "뉴스 한 줄 요약",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFBFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFCFBFB), width: 1.5),
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
                          child: Text(
                            combinedNewsSummary.isNotEmpty
                                ? combinedNewsSummary
                                : "요약된 뉴스가 없습니다.",
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(
                            isPlaying
                                ? 'assets/images/Sound_Off.png'
                                : 'assets/images/Sound_On.png',
                            width: 26,
                            height: 26,
                          ),
                          onPressed: _toggleTTS,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
