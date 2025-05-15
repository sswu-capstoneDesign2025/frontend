import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/userstore/user_store_detail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OtherUserStoreScreen extends StatefulWidget {
  const OtherUserStoreScreen({super.key});

  @override
  State<OtherUserStoreScreen> createState() => _OtherUserStoreScreenState();
}

class _OtherUserStoreScreenState extends State<OtherUserStoreScreen> {
  int _selectedIndex = 0;
  List<dynamic> otherUserRecords = [];

  final String defaultProfileUrl = 'https://i.pravatar.cc/150?img=1';
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    fetchOtherUserRecords();
  }

  Future<void> fetchOtherUserRecords() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/other-user-records/"));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        setState(() {
          otherUserRecords = json.decode(decodedBody);
        });
      } else {
        print('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching records: $e');
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
      body: otherUserRecords.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: otherUserRecords.length,
              itemBuilder: (context, index) {
                final record = otherUserRecords[index];
                final profileUrl = (record['profileUrl'] ?? '').isNotEmpty
                    ? record['profileUrl']
                    : defaultProfileUrl;

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
                            backgroundImage: NetworkImage(profileUrl),
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
