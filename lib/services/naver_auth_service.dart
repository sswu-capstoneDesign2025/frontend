//naver_auth_service.dart

import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaverAuthService {
  static Future<String?> loginWithNaver() async {
    try {
      // 1. FastAPI에서 redirect_url 요청
      final res = await http.get(Uri.parse("${dotenv.env['API_BASE_URL']}/auth/naver/login"));
      final redirectUrl = jsonDecode(res.body)["redirect_url"];

      // 2. WebAuth로 사용자 로그인 진행
      final result = await FlutterWebAuth2.authenticate(
        url: redirectUrl,
        callbackUrlScheme: "myapp", // NAVER_REDIRECT_URI와 일치해야 함
      );

      // 3. result는 콜백 URI (myapp://auth?code=...&state=...)
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      // 4. FastAPI 백엔드로 callback 요청
      final tokenRes = await http.get(
        Uri.parse("${dotenv.env['API_BASE_URL']}/auth/naver/callback?code=$code&state=$state"),
      );

      final tokenJson = jsonDecode(tokenRes.body);
      return tokenJson["access_token"];
    } catch (e) {
      print("❌ 네이버 로그인 실패: $e");
      return null;
    }
  }
}
