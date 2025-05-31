import 'dart:io';
import 'package:flutter/material.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capstone_story_app/services/custom_http_client.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../../widgets/custom_layout.dart';
import '../auth/login_page.dart';
import 'package:file_picker/file_picker.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  File? _profileImage;
  String? nickname;
  String? name;
  String? imageUrl;
  Uint8List? _webImageBytes;
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> uploadProfileImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final client = CustomHttpClient(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/profile-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await client.send(request);

    if (response.statusCode == 200) {
      print('✅ 이미지 업로드 성공');
    } else {
      print('❌ 이미지 업로드 실패: ${response.statusCode}');
    }
    await _loadUserData();
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        _profileImage = file;
      });
      await uploadProfileImage(file);
    }
  }

  Future<void> _pickImageWeb() async {
    print('📁 [DEBUG] _pickImageWeb 진입');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    // 1) 사용자가 파일 선택 창에서 취소한 경우
    if (result == null) {
      print('📁 [DEBUG] 파일 선택 취소됨');
      return; // 아무 메시지도 띄우지 않거나, 원하면 "취소되었습니다" 토스트
    }

    final PlatformFile file = result.files.single;
    print('📁 [DEBUG] pickFiles 파일명=${file.name}, 확장자=${file.extension}, size=${file.size}');

    // 2) 확장자 검증(사실 FilePicker가 필터링해주지만, 안전장치로 한 번 더)
    final ext = file.extension?.toLowerCase();
    if (ext == null || !['jpg', 'jpeg', 'png'].contains(ext)) {
      print('📁 [DEBUG] 유효하지 않은 확장자: .$ext');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 지원되지 않는 파일 형식입니다 (jpg, png만 가능)')),
      );
      return;
    }

    // 3) 바이트 로드 실패(rare)
    if (file.bytes == null) {
      print('📁 [DEBUG] 파일 바이트 로드 실패');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 파일을 불러오는 중 오류가 발생했습니다')),
      );
      return;
    }

    // 4) 정상 처리
    print('📁 [DEBUG] 정상 선택된 이미지, 업로드 시작');
    setState(() => _webImageBytes = file.bytes!);
    await uploadProfileImageWeb(file.bytes!);
  }



  Future<void> uploadProfileImageWeb(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? prefs.getString('jwt_token');

    final client = CustomHttpClient(context);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/profile-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'profile.png',
        contentType: MediaType('image', 'png'),
      ),
    );

    final response = await client.send(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('✅ 웹 이미지 업로드 성공: $responseBody');
    } else {
      print('❌ 업로드 실패 (${response.statusCode}): $responseBody');
    }
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService().fetchUserProfile(context);
    if (userData != null) {
      setState(() {
        nickname = userData['nickname'];
        name = userData['name'];
        imageUrl = userData['profile_image'];
      });
    }
  }

  /// 로그아웃
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final profileRadius = screenWidth * 0.3;
    final buttonWidth = screenWidth * 0.85;

    return CustomLayout(
      isHome: false,
      backgroundColor: const Color(0xFFE3FFCD),
      child: Container(
        color: const Color(0xFFE3FFCD),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 프로필 이미지
                GestureDetector(
                  onTap: () => kIsWeb ? _pickImageWeb() : _pickImage(),
                  child: CircleAvatar(
                    radius: profileRadius,
                    backgroundImage: _webImageBytes != null
                        ? MemoryImage(_webImageBytes!)
                        : (imageUrl != null
                        ? NetworkImage('$baseUrl${imageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}')
                        : const AssetImage('assets/images/profile_sample.png')) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),

                // 닉네임 / 이름
                Text(
                  nickname ?? '닉네임 불러오는 중...',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HakgyoansimGeurimilgi',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name ?? '이름 불러오는 중...',
                  style: TextStyle(
                    fontSize: screenWidth * 0.065,
                    fontFamily: 'HakgyoansimGeurimilgi',
                  ),
                ),
                const SizedBox(height: 8),

                // 수정 버튼
                ElevatedButton(
                  onPressed: _showEditOptions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                  ),
                  child: Text(
                    '수정',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontFamily: 'HakgyoansimGeurimilgi',
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                _buildMenuButton('비밀번호 변경', () {}, buttonWidth),
                _buildMenuButton('앱 설정', () {}, buttonWidth),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOutlinedButton('로그아웃', _logout, width: buttonWidth * 0.48),
                    const SizedBox(width: 12),
                    _buildOutlinedButton('탈퇴', _logout, width: buttonWidth * 0.48),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 수정 버튼 눌렀을 때 나올 바텀 시트
  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('프로필 사진 변경'),
              onTap: () {
                Navigator.pop(context);
                if (kIsWeb) {
                  _pickImageWeb();
                } else {
                  _pickImage();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('프로필 사진 삭제'),
              onTap: () {
                Navigator.pop(context);
                deleteProfileImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 사진 삭제 API 호출
  Future<void> deleteProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? prefs.getString('jwt_token');

    final client = CustomHttpClient(context);
    final request = http.Request('DELETE', Uri.parse('$baseUrl/auth/profile-image'));
    request.headers['Authorization'] = 'Bearer $token';

    final response = await client.send(request);
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('🗑️ 프로필 사진 삭제 성공');
    } else {
      print('❌ 프로필 사진 삭제 실패: ${response.statusCode}');
    }
    await _loadUserData(); // 삭제 후 UI 갱신
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: width,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'HakgyoansimGeurimilgi',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
      String text,
      VoidCallback onPressed, {
        double? width,
        double? height,
      }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        final effectiveWidth = width ?? screenWidth * 0.45; // 기본 45%
        final effectiveHeight = height ?? screenWidth * 0.13; // 기본 높이 비율
        final fontSize = (screenWidth * 0.05).clamp(14.0, 22.0); // 글씨 크기 비율 + 최대/최소 제한

        return SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'HakgyoansimGeurimilgi',
              ),
            ),
          ),
        );
      },
    );
  }
}
