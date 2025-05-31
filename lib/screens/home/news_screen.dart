import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/services/news_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';
import 'package:audioplayers/audioplayers.dart';
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

  final String backendIp = '192.168.30.4'; 

  @override
  void initState() {
    super.initState();
    print("🚀 NewsScreen initState 실행됨");

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => isPlaying = false);
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
        final uri = Uri.parse('http://$backendIp:8000/tts/synthesize');
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': combinedNewsSummary}),
        );
        final decoded = jsonDecode(res.body);
        final audioUrlPath = decoded['file_url'];

        if (audioUrlPath != null) {
          final fullUrl = 'http://$backendIp:8000$audioUrlPath';
          await _audioPlayer.stop();            
          await _audioPlayer.play(UrlSource(fullUrl));
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
                      "뉴스 한 줄 요약",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (widget.inputText != null && widget.inputText!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 4),
                      child: Text(
                         '"${widget.inputText}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
