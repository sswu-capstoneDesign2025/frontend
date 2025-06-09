// lib/services/custom_http_client.dart

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_story_app/screens/auth/login_page.dart';

class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final BuildContext context;

  CustomHttpClient(this.context);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('access_token') ?? prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401 && context.mounted) {
      await _handleUnauthorized(context);
    }

    return response;
  }

  Future<void> _handleUnauthorized(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('access_token');
    await prefs.setBool('is_logged_in', false);

    // 이미 로그인 화면이 아닐 때만 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }
}
