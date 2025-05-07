import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart';

class NewsCard extends StatefulWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isPlaying = false;

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      print("🔊 TTS 재생: ${widget.news.title}");
      // 실제 TTS 재생 함수 호출 추가 예정
    } else {
      print("⏸️ TTS 정지: ${widget.news.title}");
      // 실제 TTS 정지 함수 호출 추가 예정
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF446F24), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 텍스트 부분
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.news.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.news.content),
              ],
            ),
          ),

          // 아이콘 버튼
          IconButton(
            icon: Image.asset(
              isPlaying
                  ? 'assets/images/Sound_Off.png' 
                  : 'assets/images/Sound_On.png', 
              width: 30,
              height: 30,
            ),
            onPressed: _togglePlay,
          ),
        ],
      ),
    );
  }
}
