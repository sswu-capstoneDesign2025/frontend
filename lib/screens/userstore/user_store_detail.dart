import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserStoreDetail extends StatelessWidget {
  final String date;
  final String title;
  final String content;

  const UserStoreDetail({
    super.key,
    required this.date,
    required this.title,
    required this.content,
  });

  String formatDate(String rawDate) {
    try {
      DateTime parsedDate =
          DateTime.parse(rawDate); // "2025-05-11T08:30:00" 형식이어야 함
      return DateFormat('yyyy-MM-dd일 hh:mm a')
          .format(parsedDate); // "2025-05-11일 08:30 AM"
    } catch (e) {
      return rawDate; // 파싱 실패 시 원본 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '기록 상세 보기',
          style: TextStyle(
            fontFamily: 'HakgyoansimGeurimilgi',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE3FFCD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDate(date),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'HakgyoansimGeurimilgi',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '요약 내용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'HakgyoansimGeurimilgi',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'HakgyoansimGeurimilgi',
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '전체 내용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'HakgyoansimGeurimilgi',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'HakgyoansimGeurimilgi',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
