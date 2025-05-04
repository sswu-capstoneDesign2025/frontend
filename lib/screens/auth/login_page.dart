import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:capstone_story_app/screens/auth/username_login_page.dart';
import 'package:capstone_story_app/services/kakao_auth_service.dart';

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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: labelColor,
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
              const SizedBox(height: 1),

              const Text(
                '나의 소중한 친구',
                style: TextStyle(
                  fontFamily: 'HakgyoansimGeurimilgi',
                  fontSize: 20,
                  color: Color(0xFF78CF97),
                ),
              ),
              const SizedBox(height: 4),

              const Text(
                '말벗',
                style: TextStyle(
                  fontFamily: 'BaedalJua',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C7D52),
                ),
              ),
              const SizedBox(height: 40),

              // 일반 로그인
              _buildLoginButton(
                color: const Color(0xFF78CF97),
                icon: const Icon(Icons.eco, color: Colors.white),
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
                  width: 24,
                  height: 24,
                ),
                label: '네이버 로그인',
                labelColor: Colors.white,
                onPressed: () {
                  // TODO: 네이버 OAuth 로직
                },
              ),
              const SizedBox(height: 20),

              // 카카오 로그인
              _buildLoginButton(
                color: const Color(0xFFFEE500),
                icon: SvgPicture.asset(
                  'assets/images/KakaoTalk_logo.svg',
                  width: 24,
                  height: 24,
                ),
                label: '카카오 로그인',
                labelColor: Color(0xFF3C1E1E),
                onPressed: () async {
                  try {
                    await KakaoAuthService.loginWithKakao(context);
                  } catch (e) {
                    print("카카오 로그인 실패: $e");
                  }
                },
              ),
              const Spacer(),

              // 회원가입
              GestureDetector(
                onTap: () {
                  // TODO: Navigator.push to SignUpPage
                },
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF3C7D52),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
