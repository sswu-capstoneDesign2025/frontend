import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/userstore/user_store_detail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capstone_story_app/screens/home/news_screen.dart';

class OtherUserStoreScreen extends StatefulWidget {
  const OtherUserStoreScreen({super.key});

  @override
  State<OtherUserStoreScreen> createState() => _OtherUserStoreScreenState();
}

class _OtherUserStoreScreenState extends State<OtherUserStoreScreen> {
  int _selectedIndex = 0;
  List<dynamic> allRecords = [];
  List<dynamic> filteredRecords = [];

  final String defaultProfileUrl = 'https://i.pravatar.cc/150?img=1';
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  // 필터 상태
  String selectedCategory = '';
  String sortOrder = '최신순'; // 기본값
  DateTimeRange? selectedDateRange;
  String? selectedRegion;
  String? selectedTopic;

  final List<String> regions = ['서울', '부산', '대구', '인천', '광주', '대전', '용산', '세종'];
  final List<String> topics = ['일상', '사랑', '설화'];

  @override
  void initState() {
    super.initState();
    fetchOtherUserRecords();
  }

  Future<void> fetchOtherUserRecords() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/other-user-records/"));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final records = json.decode(decodedBody);
        setState(() {
          allRecords = records;
          filteredRecords = records;
        });
      } else {
        print('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void applyFilters() {
    setState(() {
      filteredRecords = allRecords.where((record) {
        final recordDate =
            DateTime.tryParse(record['date'] ?? '') ?? DateTime.now();

        final matchDate = selectedDateRange == null ||
            (recordDate.isAfter(selectedDateRange!.start
                    .subtract(const Duration(days: 1))) &&
                recordDate.isBefore(
                    selectedDateRange!.end.add(const Duration(days: 1))));

        final matchRegion =
            selectedRegion == null || record['region'] == selectedRegion;
        final matchTopic =
            selectedTopic == null || record['topic'] == selectedTopic;

        return matchDate && matchRegion && matchTopic;
      }).toList();

      // ✅ 정렬 적용
      if (sortOrder == '랜덤순') {
        filteredRecords.shuffle();
      } else if (sortOrder == '최신순') {
        filteredRecords.sort((a, b) {
          final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1900);
          final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA); // 최신순
        });
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // 배경색 전체 변경 (캘린더 배경)
            scaffoldBackgroundColor: const Color(0xFFF1FFF1), // 연한 초록

            // 선택된 날짜 색상 (primary는 중심 테마 색)
            primaryColor: const Color(0xFF7AC37A),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7AC37A), // 선택된 날짜 배경
              onPrimary: Colors.white, // 선택된 날짜 텍스트
              surface: Color(0xFFF1FFF1), // 다이얼로그 표면 배경
              onSurface: Colors.black, // 일반 텍스트
            ),

            dialogBackgroundColor: const Color(0xFFF1FFF1), // 다이얼로그 내부 배경색
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[900],
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      applyFilters();
    }
  }

  void resetFilter() {
    setState(() {
      selectedDateRange = null;
      selectedRegion = null;
      selectedTopic = null;
      filteredRecords = allRecords;
    });
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCategory == label) {
            selectedCategory = '';
            resetFilter();
          } else {
            selectedCategory = label;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB5E1B5) : Colors.white,
          border: Border.all(color: const Color(0xFF7AC37A)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.green[900],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          maxHeight: 260, // 고정 높이
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F5E6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7AC37A)),
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // ✅ 중앙 정렬
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center, // ✅ 중앙 정렬
                  children: [
                    _buildFilterChip("날짜",
                        isSelected: selectedCategory == '날짜'),
                    _buildFilterChip("지역",
                        isSelected: selectedCategory == '지역'),
                    _buildFilterChip("주제",
                        isSelected: selectedCategory == '주제'),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedCategory == '날짜')
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5E1B5),
                        foregroundColor: Colors.green[900],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _selectDateRange(context),
                      child: Text(
                        selectedDateRange == null
                            ? '날짜 선택'
                            : '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (selectedCategory == '지역')
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center, // ✅ 중앙 정렬
                    children: regions.map((region) {
                      return ChoiceChip(
                        label: Text(region),
                        selected: selectedRegion == region,
                        selectedColor: const Color(0xFFB5E1B5),
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          setState(() {
                            selectedRegion = region;
                          });
                          applyFilters();
                        },
                      );
                    }).toList(),
                  ),
                if (selectedCategory == '주제')
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center, // ✅ 중앙 정렬
                    children: topics.map((topic) {
                      return ChoiceChip(
                        label: Text(topic),
                        selected: selectedTopic == topic,
                        selectedColor: const Color(0xFFB5E1B5),
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          setState(() {
                            selectedTopic = topic;
                          });
                          applyFilters();
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                sortOrder = '랜덤순';
                applyFilters();
              });
            },
            child: Text(
              '• 랜덤순  ',
              style: TextStyle(
                fontWeight:
                    sortOrder == '랜덤순' ? FontWeight.bold : FontWeight.normal,
                color: sortOrder == '랜덤순' ? Colors.green[900] : Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                sortOrder = '최신순';
                applyFilters();
              });
            },
            child: Text(
              '• 최신순',
              style: TextStyle(
                fontWeight:
                    sortOrder == '최신순' ? FontWeight.bold : FontWeight.normal,
                color: sortOrder == '최신순' ? Colors.green[900] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map record) {
    final profileUrl = (record['profileUrl'] ?? '').isNotEmpty
        ? record['profileUrl']
        : defaultProfileUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(profileUrl),
            backgroundColor: Colors.grey[300],
          ),
          title: Text(
            record['author'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            record['title'] ?? '',
            style: const TextStyle(fontSize: 13),
          ),
          trailing: const Icon(Icons.volume_up_rounded),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const NewsScreen(inputText: "오늘 뉴스 알려줘"),
        ),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: Column(
        children: [
          _buildFilterArea(),
          _buildSortRow(),
          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(child: Text('결과 없음'))
                : ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) =>
                        _buildRecordCard(filteredRecords[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
