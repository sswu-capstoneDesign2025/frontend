// 카카오 로그인 로직 (API 연동)
//kakao_auth_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/auth/kakao_extra_info_page.dart';

class KakaoAuthService {
  static const String _baseUrl = "http://192.168.45.244:8000"; // ← 여기만 바꾸면 전체 반영

  static Future<void> loginWithKakao(BuildContext context) async {
    // 1. 로그인 URL 요청
    final loginUrlRes = await http.get(Uri.parse("$_baseUrl/auth/kakao/login"));
    final redirectUrl = jsonDecode(loginUrlRes.body)["redirect_url"];
    print("카카오 로그인 URL: $redirectUrl");
    // 2. 사용자 인증
    final result = await FlutterWebAuth2.authenticate(
      url: redirectUrl,
      callbackUrlScheme: "http",
    );

    // 3. 인가코드 추출
    final code = Uri.parse(result).queryParameters["code"];

    // 4. 백엔드에 code 전달
    final callbackRes = await http.get(
      Uri.parse("$_baseUrl/auth/kakao/callback?code=$code"),
    );

    if (callbackRes.statusCode == 200) {
      final json = jsonDecode(callbackRes.body);
      final token = json["access_token"];
      await AuthService.saveToken(token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (callbackRes.statusCode == 307 || callbackRes.statusCode == 302) {
      final location = callbackRes.headers["location"];
      final uri = Uri.parse(location!);
      final kakaoId = uri.queryParameters["kakao_id"];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KakaoExtraInfoPage(kakaoId: kakaoId!),
        ),
      );
    } else {
      throw Exception("카카오 로그인 실패: ${callbackRes.body}");
    }
  }

  static Future<String> submitKakaoExtraInfo({
    required String kakaoId,
    required String name,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/kakao/extra-info"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kakao_id": kakaoId,
        "name": name,
        "phone_number": phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["access_token"];
    } else {
      throw Exception("추가 정보 등록 실패: ${response.body}");
    }
  }
}

