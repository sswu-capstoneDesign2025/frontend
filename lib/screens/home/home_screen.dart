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
    if (_isCountdown) return; // 카운트다운 중엔 무시
    if (!await _recorder.hasPermission()) {
      print('❌ 마이크 권한 없음');
      return;
    }

    if (_isRecording) {
      // 녹음 종료
      _dotTimer?.cancel();
      _activeDot = 0;

      String? filePath;
      late Uint8List webBytes;

      if (kIsWeb) {
        await _recorder.stop();
        await _webSubscription?.cancel();
        await Future.delayed(const Duration(milliseconds: 200));
        final webBytes = Uint8List.fromList(_webChunks);
        final wavBytes = addWavHeader(webBytes, 16000, 1);
        _webChunks.clear();
        print('⛔ 웹 수동 중단, bytes length=${wavBytes.length}');
        await _handleUploadAndSTT(filePath: null, webBytes: wavBytes);
      } else {
        filePath = await _recorder.stop();
        print('⛔ 수동 중단 (파일): $filePath');
        await _handleUploadAndSTT(filePath: filePath);
      }

      setState(() => _isRecording = false);
    } else {
      await _startCountdownAndRecord(); // 카운트다운 후 녹음
    }
  }

  Future<void> _startCountdownAndRecord() async {
    setState(() {
      _isCountdown = true;
      _countdown = 3;
    });

    for (int i = 3; i >= 1; i--) {
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _countdown = null;
      _isCountdown = false;
      _isRecording = true;
      _recordStartTime = DateTime.now();
    });

    _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _activeDot = (_activeDot + 1) % 3;
      });
    });

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
        print('🔸 chunk received: ${data.length} bytes, total=${_webChunks.length}');
      });
    } else {
      final dir = await getTemporaryDirectory();
      final tmpPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: tmpPath,
      );
      print('▶️ 파일 녹음 시작: $tmpPath');
    }
  }

  Future<void> _handleUploadAndSTT({
    String? filePath,
    Uint8List? webBytes,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload/audio/'),
    );

    if (webBytes != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webBytes,
          filename: 'voice_record.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );
      print('📤 웹 bytes 업로드, length=${webBytes.length}');
    } else if (filePath != null) {
      req.files.add(await http.MultipartFile.fromPath('file', filePath));
      print('📤 파일 업로드: $filePath');
    } else {
      return;
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();
    print('🔍 업로드 응답 status=${res.statusCode}, body=$body');

    if (res.statusCode != 200) {
      print('🛑 업로드 실패');
      return;
    }

    final fileUrl = jsonDecode(body)['file_url'];

    final sttRes = await http.post(
      Uri.parse('$_baseUrl/transcribe/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'file_url': fileUrl}),
    );
    final decoded = utf8.decode(sttRes.bodyBytes);
    print('🔍 STT 요청 status=${sttRes.statusCode}, body=$decoded');

    if (sttRes.statusCode == 200) {
      final text = jsonDecode(decoded)['transcribed_text'] ?? '변환 실패';
      setState(() => _transcribedText = text);
      print('📝 변환된 텍스트: $text');
    } else {
      print('🛑 STT 오류: $decoded');
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
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      backgroundColor: const Color(0xFFE3FFCD),
      titleText: "말벗",
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 25),

            // 녹음 버튼 + 점
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                //ui 밀림 방지 공간
                const SizedBox(height: 30),

                // 실제 점 표시
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
                        width: 290,
                        height: 290,
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
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '$_countdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'HakgyoansimGeurimilgi',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),


            const SizedBox(height: 50),

            // 📦 흰색 버튼 박스
            Container(
              width: 400,
              height: 280,
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
                                      () {}),
                            ),
                            Expanded(
                              child: _buildGridButton(
                                  'assets/images/health.svg',
                                  "건강",
                                      () {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child:
                    Container(width: 2, height: 200, color: Colors.grey[300]),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child:
                    Container(width: 300, height: 2, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
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
          Text(label, style: const TextStyle(fontSize: 24)),
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
