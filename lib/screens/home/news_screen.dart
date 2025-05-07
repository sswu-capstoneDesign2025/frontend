import 'package:flutter/material.dart';
import 'package:capstone_story_app/models/news_model.dart'; 
import 'package:capstone_story_app/widgets/news_card.dart'; 
import 'package:capstone_story_app/widgets/custom_layout.dart';


class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<News> newsList = [
      News(title: "정부, 기준금리 동결", content: "한국은행이 이자율을 그대로 두기로 했대요."),
      News(title: "비 오는 날, 교통사고 증가", content: "비 오면 도로가 미끄러워져서 사고가 많아져요."),
    ];

    return CustomLayout(
      selectedIndex: 0,
      onItemTapped: (index) {
      },
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 17),
              child: Text(
                "오늘의 뉴스 모음",
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
                itemBuilder: (context, index) => NewsCard(news: newsList[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
