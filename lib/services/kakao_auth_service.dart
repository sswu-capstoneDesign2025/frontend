// 카카오 로그인 로직 (API 연동)
// kakao_auth_service.dart

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/auth/kakao_extra_info_page.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/root_decider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoAuthService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? "http://localhost:8000";
  static void _disableLinkStream() {
    RootDeciderState.setLinkListening(false);
  }

  static void _enableLinkStream() {
    RootDeciderState.setLinkListening(true);
  }

  /// 브라우저로 카카오 로그인 URL을 열고, 딥링크 콜백은 RootDecider에서 처리합니다.
  static Future<void> loginWithKakao(BuildContext context) async {
    try {
      _disableLinkStream();

      print("🟡 1. 로그인 URL 요청 시작");
      final loginUrlRes = await http.get(Uri.parse("$_baseUrl/auth/kakao/login"));
      final redirectUrl = jsonDecode(loginUrlRes.body)["redirect_url"];
      print("🟡 2. 로그인 리디렉션 URL 수신: $redirectUrl");

      print("🟡 3. 외부 브라우저로 로그인 URL 열기");
      await launchUrlString(
        redirectUrl,
        mode: LaunchMode.externalApplication,
      );

      // 콜백된 딥링크(myapp://auth?…)는 RootDecider가 _handleUri에서 처리합니다.
    } catch (e) {
      print("❌ 카카오 로그인 중 오류: $e");
    } finally {
      _enableLinkStream();
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
