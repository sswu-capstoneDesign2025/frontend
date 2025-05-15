import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/userstore/user_store_detail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserStoreScreen extends StatefulWidget {
  const UserStoreScreen({super.key});

  @override
  State<UserStoreScreen> createState() => _UserStoreScreenState();
}

class _UserStoreScreenState extends State<UserStoreScreen> {
  int _selectedIndex = 2; // 예시로 다른 탭 인덱스
  List<Map<String, dynamic>> userRecords = [];
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    _fetchUserRecords();
  }

  Future<void> _fetchUserRecords() async {
    final response =
        await http.get(Uri.parse("$baseUrl/summary-notes/"));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
      final List<dynamic>? data = jsonResponse['notes'];
      if (data != null && data is List) {
        setState(() {
          userRecords = data.map((item) {
            return {
              'date': item['created_at'] ?? '',
              'title': item['sum_title'] ?? '',
              'content': item['content'] ?? '',
            };
          }).toList();
        });
      } else {
        print("⚠️ 'notes' 필드가 존재하지 않거나 리스트 형식이 아닙니다.");
      }
    } else {
      throw Exception('Failed to load records');
    }
  }

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
      body: userRecords.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
