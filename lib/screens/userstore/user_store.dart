// lib/screens/userstore/user_store_screen.dart
import 'package:flutter/material.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/userstore/user_store_detail.dart';

class UserStoreScreen extends StatefulWidget {
  const UserStoreScreen({super.key});

  @override
  State<UserStoreScreen> createState() => _UserStoreScreenState();
}

class _UserStoreScreenState extends State<UserStoreScreen> {
  int _selectedIndex = 2; // 예시로 다른 탭 인덱스

  // 샘플 데이터: 날짜, 제목, 전체 내용
  final List<Map<String, String>> userRecords = [
    {
      'date': '2025.05.01',
      'title': '“옆집 다은이네 소문에 관한 얘기”',
      'content': '오늘 옆집 다은이네에 무슨 일이 있었는지 사람들이 이야기하고 있었어요. 궁금하지만 확인은 안 했어요.',
    },
    {
      'date': '2025.05.03',
      'title': '“내가 오이도를 갔다 왔던 내용”',
      'content': '오이도에 다녀왔어요. 바람도 좋고, 조개구이도 먹고 정말 행복한 하루였어요.',
    },
    {
      'date': '2025.05.04',
      'title': '“조금 피곤하지만 괜찮아요”',
      'content': '요즘 일이 많아서 조금 피곤했지만 그래도 괜찮아요. 커피 한 잔 마시면서 쉬었어요.',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: userRecords.length,
        itemBuilder: (context, index) {
          final record = userRecords[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserStoreDetail(
                    date: record['date'] ?? '',
                    title: record['title'] ?? '',
                    content: record['content'] ?? '',
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.grey[50],
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${record['date']} - ${record['title']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
