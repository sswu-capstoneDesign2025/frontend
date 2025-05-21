//auth_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  /// 일반 로그인
  static Future<void> loginWithUsernamePassword({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json["access_token"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setBool('is_logged_in', true);
    } else {
      throw Exception("로그인 실패: ${response.body}");
    }
  }

  /// 회원가입 추가
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "name": name,
        "phone_number": phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        "success": false,
        "error": error['detail'] ?? '회원가입 실패',
      };
    }
  }

  /// 아이디 중복 확인
  static Future<bool> isUsernameAvailable(String username) async {
    final url = Uri.parse('$baseUrl/auth/check-username?username=$username');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['available'] == true;
    } else {
      throw Exception('중복 확인 실패: ${response.body}');
    }
  }

  /// 사용자 정보 받아오기
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded;
    } else {
      print('❌ 사용자 정보 조회 실패: ${response.body}');
      return null;
    }
  }


  /// JWT 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  /// JWT 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// JWT 토큰 삭제
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.setBool('is_logged_in', false);
  }
}
