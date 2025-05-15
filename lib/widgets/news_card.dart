import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
      print("🔊 TTS 재생: ${widget.news.content}");
      // TODO: TTS 재생 함수 호출
    } else {
      print("⏸️ TTS 정지: ${widget.news.content}");
      // TODO: TTS 정지 함수 호출
    }
  }

  void _launchURL() async {
  final url = widget.news.url;
  if (url != null && url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    print("🔗 링크 열기 실패 (url이 null이거나 비었음): $url");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('링크를 열 수 없습니다.')),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 내용
          Text(
            widget.news.content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),

          // 하단 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _launchURL,
                icon: const Icon(Icons.link, size: 20),
                label: const Text(
                  "뉴스 자세히 보기",
                  style: TextStyle(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
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
        ],
      ),
    );
  }
}
