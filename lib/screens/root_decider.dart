// root_decider.dart

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:capstone_story_app/screens/splash/splash_screen.dart';
import 'package:capstone_story_app/screens/auth/login_page.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/auth/kakao_extra_info_page.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_story_app/main.dart';

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => RootDeciderState();
}

class RootDeciderState extends State<RootDecider> {
  static RootDeciderState? _instance;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _navigatedByDeepLink = false;

  bool _checked = false;
  bool _loggedIn = false;

  static void setLinkListening(bool enable) {
    final sub = _instance?._sub;
    if (sub != null) {
      enable ? sub.resume() : sub.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    _instance = this;
    _appLinks = AppLinks();
    _listenToLinkStream();
    _initApp();  // ← 수정: 여기서 토큰+딜레이 처리
  }

  Future<void> _initApp() async {
    // 1) 저장된 토큰 읽기
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // 2) 스플래시 최소 표시 시간 보장
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    // 3) 상태 업데이트 (build()가 LoginPage/HomeScreen 결정)
    setState(() {
      _loggedIn = isLoggedIn;
      _checked = true;
    });
  }

  void _listenToLinkStream() {
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    }, onError: (err) {
      print('❌ 링크 스트림 오류: $err');
    });
  }

  Future<void> _handleUri(Uri? uri) async {
    if (uri == null) return;
    if (uri.scheme == "myapp" && uri.host == "auth") {
      print("📦 딥링크 URI 수신: $uri");

      final isNew = uri.queryParameters["is_new_user"] == "true";
      final kakaoId = uri.queryParameters["kakao_id"];
      final token = uri.queryParameters["token"];

      if (isNew && kakaoId != null) {
        print("📥 신규 유저 → 추가정보 페이지로 이동");
        _navigatedByDeepLink = true;
        setState(() {}); // build() 재실행 → Splash 유지됨

        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => KakaoExtraInfoPage(kakaoId: kakaoId),
            ),
          ).then((_) {
            _navigatedByDeepLink = false;
            setState(() {});
          });
        });
        return;
      }

      if (token != null) {
        print("📥 기존 유저 → 토큰 저장 및 홈 이동");
        await AuthService.saveToken(token);
        setState(() {
          _loggedIn = true;
          _checked = true;
        });
      }
    }
  }


  @override
  void dispose() {
    _sub?.cancel();
    _instance = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || _navigatedByDeepLink) {
      // 스플래시 or 딥링크 처리 중이면 Splash 유지
      return const SplashScreen();
    }

    return _loggedIn ? const HomeScreen() : const LoginPage();
  }
}