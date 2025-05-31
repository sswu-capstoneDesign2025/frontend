// 추가 정보 입력 페이지
//kakao_extra_info_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../root_decider.dart';


class KakaoExtraInfoPage extends StatefulWidget {
  final String kakaoId;
  const KakaoExtraInfoPage({super.key, required this.kakaoId});

  @override
  State<KakaoExtraInfoPage> createState() => _KakaoExtraInfoPageState();
}

class _KakaoExtraInfoPageState extends State<KakaoExtraInfoPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool _isLoading = false;

  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitExtraInfo() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이름과 전화번호를 모두 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/kakao/extra-info"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "kakao_id": widget.kakaoId,
          "name": name,
          "phone_number": phone,
        }),
      );

      print("🔵 응답 status: ${response.statusCode}");
      print("🔵 응답 body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        await AuthService.saveToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RootDecider()),
        );
      } else {
        print("오류 발생: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("정보 제출에 실패했습니다.")),
        );
      }
    } catch (e) {
      print("예외 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("서버 통신 중 오류가 발생했습니다.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3FFCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3FFCD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '추가 정보 입력',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontFamily: 'HakgyoansimGeurimilgi',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "이름을 입력해주세요",
                    hintStyle: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 25),

                const Text("휴대폰번호", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "휴대폰 번호를 입력해주세요",
                    hintStyle: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitExtraInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78CF97),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "제출",
                      style: TextStyle(
                        fontFamily: 'HakgyoansimGeurimilgi',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}