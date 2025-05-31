// Updated UserStoreScreen with 날짜, 지역, 주제 필터 포함
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/userstore/user_store_detail.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_story_app/screens/home/news_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/custom_http_client.dart';
import 'package:audioplayers/audioplayers.dart';

class UserStoreScreen extends StatefulWidget {
  const UserStoreScreen({super.key});

  @override
  State<UserStoreScreen> createState() => _UserStoreScreenState();
}

class _UserStoreScreenState extends State<UserStoreScreen> {
  List<Map<String, dynamic>> allRecords = [];
  List<Map<String, dynamic>> filteredRecords = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedIndex = 0;
  final String defaultProfileUrl = 'https://i.pravatar.cc/150?img=1';
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  String selectedCategory = '';
  DateTimeRange? selectedDateRange;
  String? selectedRegion;
  String? selectedTopic;
  String sortOrder = '최신순';

  final List<String> regions = ['서울', '부산', '대구', '인천', '광주', '대전', '용산', '세종'];
  final List<String> topics = ['일상', '사랑', '설화'];

  @override
  void initState() {
    super.initState();
    fetchOtherUserRecords();
  }

  Future<void> fetchOtherUserRecords() async {
    try {
      final client = CustomHttpClient(context);
      final response =
          await client.get(Uri.parse("$baseUrl/other-user-records/"));

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
                foregroundColor: Colors.black,
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

  @override
  void dispose() {
    _audioPlayer.dispose(); // 🎧 음성 플레이어 메모리 정리
    super.dispose();
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedCategory == label) {
            selectedCategory = '';
            resetFilter();
          } else {
            selectedCategory = label;

            // ✅ 다른 필터 초기화
            selectedDateRange = null;
            selectedRegion = null;
            selectedTopic = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x5E446F24) : Colors.white,
          border: Border.all(color: const Color(0xFF446F24), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'HakgyoansimGeurimilgi',
            fontSize: (screenWidth * 0.07).clamp(16.0, 25.0),
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterArea() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: screenWidth * 0.8,
          maxHeight: (screenHeight * 0.35).clamp(200.0, 350.0),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE3FFCD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF446F24),
              width: 2,
            ),
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
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB5E1B5),
                          foregroundColor: const Color(0xFF446F24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () => _selectDateRange(context),
                        child: Text(
                          selectedDateRange == null
                              ? '날짜 선택'
                              : '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
                          style: TextStyle(
                            fontFamily: 'HakgyoansimGeurimilgi',
                            fontSize: (screenWidth * 0.05).clamp(14.0, 24.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (selectedCategory == '지역')
                  SizedBox(
                    height: (screenWidth * 0.25).clamp(120.0, 200.0),
                    child: GridView.count(
                      crossAxisCount: 4,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: regions.map((region) {
                        final bool isSelected = selectedRegion == region;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRegion = region;
                            });
                            applyFilters();
                          },
                          child: Container(
                            alignment: Alignment.center, // 텍스트 중앙 정렬
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0x5E446F24)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF446F24),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              region,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'HakgyoansimGeurimilgi',
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    (screenWidth * 0.06).clamp(14.0, 24.0),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (selectedCategory == '주제')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8), // ✅ 여기로 이동
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: topics.map((topic) {
                        final bool isSelected = selectedTopic == topic;
                        return ChoiceChip(
                          showCheckmark: false,
                          avatar: null,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          label: Text(
                            topic,
                            style: TextStyle(
                              fontFamily: 'HakgyoansimGeurimilgi',
                              fontWeight: FontWeight.w600,
                              fontSize: (screenWidth * 0.06).clamp(14.0, 24.0),
                              color: Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0x5E446F24),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: const Color(0xFF446F24),
                              width: 2,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              selectedTopic = topic;
                            });
                            applyFilters();
                          },
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
                fontFamily: 'HakgyoansimGeurimilgi',
                fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
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
                fontFamily: 'HakgyoansimGeurimilgi',
                fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final profileUrl = (record['profileUrl'] ?? '').isNotEmpty
        ? record['profileUrl']
        : defaultProfileUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF446F24), width: 2.0),
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
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: (record['profileUrl'] ?? '').isNotEmpty
                  ? NetworkImage(record['profileUrl'])
                  : const AssetImage('assets/images/baru.png') as ImageProvider,
            ),
          ),
          title: Text(
            record['author'] ?? '',
            style: TextStyle(
              fontFamily: 'HakgyoansimGeurimilgi',
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          subtitle: Text(
            record['title'] ?? '',
            style: TextStyle(
              fontFamily: 'HakgyoansimGeurimilgi',
              fontSize: screenWidth * 0.045,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () async {
              final content = record['content'] ?? '';
              if (content.trim().isEmpty) return;

              final ttsUrl = "$baseUrl/tts/synthesize";
              final response = await http.post(
                Uri.parse(ttsUrl),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'text': content}),
              );

              if (response.statusCode == 200) {
                final result = json.decode(utf8.decode(response.bodyBytes));
                final audioUrl = "$baseUrl${result['file_url']}";
                await _audioPlayer.play(UrlSource(audioUrl));
              } else {
                print("TTS 실패: ${response.body}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('음성 생성 실패')),
                );
              }
            },
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    return CustomLayout(
      isHome: false,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildFilterArea(),
            _buildSortRow(),
            Expanded(
              child: filteredRecords.isEmpty
                  ? Center(
                      child: Text('결과 없음',
                          style: TextStyle(
                            fontFamily: 'HakgyoansimGeurimilgi',
                            fontWeight: FontWeight.w500,
                            fontSize: (screenWidth * 0.05).clamp(16.0, 22.0),
                          )),
                    )
                  : ListView.builder(
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) =>
                          _buildRecordCard(filteredRecords[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
