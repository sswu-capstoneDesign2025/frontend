// ✅ [1] NewsScreen - 뉴스 탭에서 홈/수다로 이동 기능 추가

import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart';
import 'package:capstone_story_app/widgets/news_card.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/services/news_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';

class NewsScreen extends StatefulWidget {
  final String inputText;

  const NewsScreen({super.key, required this.inputText});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNewsFromAPI();
  }

  Future<void> loadNewsFromAPI() async {
    try {
      final summaries = await fetchNewsFromText(widget.inputText);

      setState(() {
        newsList = summaries
            .map((e) => News(
                  title: e['title'] ?? e['url'] ?? '',
                  content: e['summary'] ?? '',
                  url: e['url'] ?? '',
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('에러 발생: $e');
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
      selectedIndex: 0,
      onItemTapped: _onItemTapped,
      body: isLoading
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
                      "🔍관련 뉴스 모음",
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
