// lib/screens/home/home_screen.dart

import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/screens/home/news_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';
import 'package:capstone_story_app/utils/audio_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_story_app/screens/health/health_screen.dart';
import 'package:capstone_story_app/screens/home/weather_screen.dart';


import '../auth/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isCountdown = false;
  String? _transcribedText;
  DateTime? _recordStartTime;
  int _selectedIndex = 1;
  StreamSubscription<Uint8List>? _webSubscription;
  List<int> _webChunks = [];
  int _activeDot = 0;
  Timer? _dotTimer;
  int? _countdown;
  String _sessionState = "initial";

  @override
  void initState() {
    super.initState();
    _ensureLoggedIn();
  }

  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<void> _ensureLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _onItemTapped(int index) {
    if (_isCountdown) return; // 카운트다운 중에는 다른 화면 이동 방지
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const NewsScreen(inputText: "오늘 뉴스 알려줘"),
        ),
            (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OtherUserStoreScreen()),
            (route) => false,
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _toggleVoiceInteraction() async {
    if (_isCountdown) {
      print('⚠️ 카운트다운 중이라 무시됨');
      return;
    }

    if (!await _recorder.hasPermission()) {
      print('❌ 마이크 권한 없음');
      return;
    }

    if (_isRecording) {
      _dotTimer?.cancel();
      _activeDot = 0;
      setState(() => _isRecording = false); // 먼저 false 처리

      String? filePath;
      Uint8List? webBytes;

      try {
        if (kIsWeb) {
          await _recorder.stop();
          await _webSubscription?.cancel();
          await Future.delayed(const Duration(milliseconds: 200));
          webBytes = Uint8List.fromList(_webChunks);
          final wavBytes = addWavHeader(webBytes, 16000, 1);
          _webChunks.clear();
          print('⛔ 웹 수동 중단, bytes length=${wavBytes.length}');
          await _handleVoiceInteraction(webBytes: wavBytes);
        } else {
          filePath = await _recorder.stop();
          print('⛔ 수동 중단 (파일): $filePath');
          await _handleVoiceInteraction(filePath: filePath);
        }
      } catch (e) {
        print('🛑 녹음 종료 처리 중 오류: $e');
      } finally {
        // 혹시라도 예외 발생 시에도 항상 isRecording = false 보장
        setState(() => _isRecording = false);
      }
    } else {
      print('⏺️ 카운트다운 시작 요청');
      await _startCountdownAndRecord();
    }
  }

  Future<void> _startCountdownAndRecord() async {
    if (_isCountdown || _isRecording) {
      print('⚠️ 이미 녹음 중이거나 카운트다운 중이라 무시됨');
      return;
    }

    setState(() {
      _isCountdown = true;
      _countdown = 3;
    });

    // 3 → 2 → 1 → null 순서로 지연 없이 처리
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown = 2);
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _countdown = 1);
    });

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      setState(() {
        _countdown = null;
        _isCountdown = false;
        _isRecording = true;
        _recordStartTime = DateTime.now();
      });

      print('▶️ 녹음 시작');

      _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
        setState(() {
          _activeDot = (_activeDot + 1) % 3;
        });
      });

      try {
        if (kIsWeb) {
          final stream = await _recorder.startStream(
            const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 16000,
              numChannels: 1,
            ),
          );
          _webChunks = [];
          _webSubscription = stream.listen((data) {
            _webChunks.addAll(data);
          });
        } else {
          final dir = await getTemporaryDirectory();
          final tmpPath =
              '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
          await _recorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: tmpPath,
          );
          print('🎙️ 파일 녹음 시작: $tmpPath');
        }
      } catch (e) {
        print('❌ 녹음 시작 실패: $e');
        setState(() => _isRecording = false);
      }
    });
  }


  Future<void> _handleVoiceInteraction({
    String? filePath,
    Uint8List? webBytes,
  }) async {
    final uri = Uri.parse('$_baseUrl/process/audio/');
    final req = http.MultipartRequest('POST', uri);

    if (webBytes != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webBytes,
          filename: 'voice.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );
    } else if (filePath != null) {
      req.files.add(await http.MultipartFile.fromPath('file', filePath));
    } else {
      return;
    }

    // 세션 상태 같이 전송
    req.fields['session_state'] = _sessionState;

    // 로그인된 사용자 이름 추가도 가능
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null) req.fields['username'] = username;

    final res = await req.send();
    final body = await res.stream.bytesToString();
    print('🎯 처리 응답: $body');

    if (res.statusCode != 200) {
      print('🛑 처리 실패');
      return;
    }

    final decoded = jsonDecode(body);
    String responseText = '응답 없음';
    final type = decoded['type'] ?? 'unknown';
    final nextState = decoded['next_state'] ?? 'initial';

    Map<String, dynamic>? result;

    if (type == 'news' || type == 'weather') {
      result = decoded['result'];
      responseText = result?['combined_summary'] ?? '요약 없음';
    } else {
      responseText = decoded['response'] ?? '응답 없음';
    }
    print('🧠 분류 결과 type: $type, nextState: $nextState');

    setState(() {
      _transcribedText = responseText;
      if (nextState == "complete") {
        print('✅ 대화 플로우 완료! 상태 초기화');
        _sessionState = "initial";
      }
      else if(nextState == "initial") {
        print('✅ 초기화 필요! 상태 초기화');
        _sessionState = "initial";
      }
      else {
        _sessionState = nextState;
      }
    });

    // 분기 처리
    if (type == 'news' || type == 'weather') {
      final result = decoded['result'];
      final summaries = result?['summaries'] as List<dynamic>?;

      if (summaries != null && summaries.isNotEmpty) {
        for (var i = 0; i < summaries.length; i++) {
          final item = summaries[i] as Map<String, dynamic>;
          final url = item['url'] ?? 'URL 없음';
          final summary = item['summary'] ?? '요약 없음';

          print('📰 [기사 ${i + 1}]\n📎 URL: $url\n📝 요약: $summary\n');
        }
      }

      final keywords = result?['keywords']?.join(', ') ?? '키워드 없음';
      print('🔍 키워드: $keywords\n\n');
      print('🧾 통합 요약문: $responseText');
    } else if (type == 'story') {
      print('🗣️ 응답: $responseText / 다음 상태: $nextState');
    } else if (type == 'invalid') {
      print('⚠️ 무의미한 입력 감지됨. 상태: $nextState');
    }
  }


  @override
  void dispose() {
    _dotTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      appBarTitle: '말벗',
      isHome: true,
      backgroundColor: const Color(0xFFE3FFCD),
      child: Container(
        color: const Color(0xFFE3FFCD),
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.maxWidth * 0.8;
            final boxHeight = constraints.maxHeight * 0.37;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        /// 녹음 버튼
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              const SizedBox(height: 30),
                              if (_isRecording)
                                Positioned(
                                  top: -30,
                                  child: _buildRecordingDots(),
                                ),
                              GestureDetector(
                                onTap: _toggleVoiceInteraction,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 300,
                                      height: 300,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF78CF97),
                                      ),
                                    ),
                                    if (_isRecording)
                                      const SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    Image.asset(
                                      'assets/images/baru.png',
                                      width: 290,
                                      height: 290,
                                    ),
                                    if (_countdown != null) ...[
                                      Container(
                                        width: 300,
                                        height: 300,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: Text(
                                          '$_countdown',
                                          key: ValueKey(_countdown),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 80,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'HakgyoansimGeurimilgi',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        /// 버튼 박스
                        Center(
                          child: Container(
                            width: boxWidth,
                            height: boxHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildGridButton(
                                                Icons.article, "뉴스", () => _onItemTapped(0)),
                                          ),
                                          Expanded(
                                            child: _buildGridButton(
                                                Icons.groups, "수다", () => _onItemTapped(2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [

                                          Expanded(
                                            child: _buildGridButton(
                                              'assets/images/weather.svg',
                                              "날씨",
                                                  () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const TodayWeatherScreen(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildGridButton(
                                                'assets/images/health.svg', "건강", () {
                                              if (_isCountdown) return;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const HealthScreen(),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 2,
                                    height: boxHeight * 0.75,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: boxWidth * 0.75,
                                    height: 2,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildGridButton(dynamic iconOrPath, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconOrPath is String
              ? SvgPicture.asset(iconOrPath, width: 60, height: 60)
              : Icon(iconOrPath, size: 60),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
              fontSize: 28,
              fontFamily: 'HakgyoansimGeurimilgi',
              fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _buildRecordingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _activeDot >= i ? 1.0 : 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF78CF97),
              ),
            ),
          ),
        );
      }),
    );
  }
}
