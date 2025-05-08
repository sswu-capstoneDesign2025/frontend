import 'package:flutter/material.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/userstore/user_store_detail.dart';

class OtherUserStoreScreen extends StatefulWidget {
  const OtherUserStoreScreen({super.key});

  @override
  State<OtherUserStoreScreen> createState() => _OtherUserStoreScreenState();
}

class _OtherUserStoreScreenState extends State<OtherUserStoreScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> otherUserRecords = [
    {
      'date': '2025-05-01',
      'title': '엄마 간병에서 손을 뗄 때가 된 걸까',
      'content': '오늘은 엄마 간병에 대해 고민이 많았다. 계속 내가 하는 게 맞을까...',
      'author': '김말벗',
      'profileUrl': 'https://i.pravatar.cc/150?img=1'
    },
    {
      'date': '2025-04-30',
      'title': '내가 오히려 혼나고 있다',
      'content': '분명 좋은 뜻이었는데, 오히려 내가 혼나고 있는 상황...',
      'author': '이말벗',
      'profileUrl': 'https://i.pravatar.cc/150?img=2'
    },
    {
      'date': '2025-04-29',
      'title': '조금 피곤하지만 참을 만하잖아',
      'content': '요즘 피곤하지만 이 정도는 괜찮다고 생각해.',
      'author': '박말벗',
      'profileUrl': 'https://i.pravatar.cc/150?img=3'
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
        itemCount: otherUserRecords.length,
        itemBuilder: (context, index) {
          final record = otherUserRecords[index];
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(record['profileUrl'] ?? ''),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['author'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            record['date'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
