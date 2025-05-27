// ✅ [1] NewsScreen - 뉴스 탭에서 홈/수다로 이동 기능 추가

import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart';
import 'package:capstone_story_app/widgets/news_card.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/services/news_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';

class NewsScreen extends StatefulWidget {
  final String? inputText;

  const NewsScreen({super.key, this.inputText});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> newsList = [];
  String combinedNewsSummary = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.inputText != null) {
      loadNewsFromAPI();
    } else {
      isLoading = false;
    }
  }

  Future<void> loadNewsFromAPI() async {
  try {
    final result = await fetchNewsFromText(widget.inputText!);
    print('💬 결과 왔다! $result');

    final summaries = result['summaries'] as List<dynamic>;
    print('📦 summaries 개수: ${summaries.length}');

    setState(() {
      newsList = summaries.map((e) => News(
        title: e['title'] ?? e['url'] ?? '',
        content: e['summary'] ?? '',
        url: e['url'] ?? '',
      )).toList();

      combinedNewsSummary = result['combined_summary'] ?? '';
      isLoading = false;
    });

    print('✅ 뉴스 리스트 변환 완료. 총 ${newsList.length}개');
  } catch (e) {
    print('❌ 에러 발생: $e');
    setState(() {
      isLoading = false;
    });
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
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 17),
                    child: Text(
                      "관련 뉴스 모음",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: newsList.length,
                      itemBuilder: (context, index) =>
                          NewsCard(news: newsList[index]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
