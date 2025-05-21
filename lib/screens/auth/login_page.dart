// lib/screens/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:capstone_story_app/screens/auth/username_login_page.dart';
import 'package:capstone_story_app/services/kakao_auth_service.dart';
import 'package:capstone_story_app/services/naver_auth_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/auth/signup_page.dart';

import '../root_decider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Widget _buildLoginButton({
    required Color color,
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
    required Color labelColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: icon,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: labelColor,
            fontFamily: 'HakgyoansimGeurimilgi',
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3FFCD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고
              Image.asset(
                'assets/images/handshake.png',
                width: 180,
                height: 180,
              ),

              const Text(
                '나의 소중한 친구',
                style: TextStyle(
                  fontFamily: 'HakgyoansimGeurimilgi',
                  fontSize: 28,
                  color: Color(0xFF78CF97),
                ),
              ),
              const SizedBox(height: 4),

              const Text(
                '말벗',
                style: TextStyle(
                  fontFamily: 'BaedalJua',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C7D52),
                ),
              ),
              const SizedBox(height: 40),

              // 일반 로그인
              _buildLoginButton(
                color: const Color(0xFF78CF97),
                icon: const Icon(Icons.eco, color: Colors.white,  size: 30),
                label: '일반 로그인',
                labelColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsernameLoginPage()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 네이버 로그인
              _buildLoginButton(
                color: const Color(0xFF03C75A),
                icon: Image.asset(
                  'assets/images/naver.png',
                  width: 34,
                  height: 34,
                ),
                label: '네이버 로그인',
                labelColor: Colors.white,
                onPressed: () async {
                  try {
                    final token = await NaverAuthService.loginWithNaver();
                    if (token != null) {
                      await AuthService.saveToken(token);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RootDecider()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("네이버 로그인 실패")),
                      );
                    }
                  } catch (e) {
                    print("네이버 로그인 예외 발생: $e");
                  }
                },
              ),
              const SizedBox(height: 20),

              // 카카오 로그인
              _buildLoginButton(
                color: const Color(0xFFFEE500),
                icon: SvgPicture.asset(
                  'assets/images/KakaoTalk_logo.svg',
                  width: 34,
                  height: 34,
                ),
                label: '카카오 로그인',
                labelColor: const Color(0xFF3C1E1E),
                onPressed: () {
                  KakaoAuthService.loginWithKakao(context);
                },
              ),
              const Spacer(),

              // 회원가입
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF3C7D52),
                    color: Color(0xFF3C7D52),
                    fontSize: 22,
                    fontFamily: 'HakgyoansimGeurimilgi',
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}