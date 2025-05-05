// 추가 정보 입력 페이지
//kakao_extra_info_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';

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
        Uri.parse("http://192.168.0.18:8000/auth/kakao/extra-info"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "kakao_id": widget.kakaoId,
          "name": name,
          "phone_number": phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        await AuthService.saveToken(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      appBar: AppBar(title: const Text("추가 정보 입력")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("환영합니다! 정보를 입력해주세요."),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "이름"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "전화번호"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitExtraInfo,
              child: const Text("제출"),
            ),
          ],
        ),
      ),
    );
  }
}
