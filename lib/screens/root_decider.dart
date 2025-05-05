// root_decider.dart

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'package:capstone_story_app/screens/splash/splash_screen.dart';
import 'package:capstone_story_app/screens/auth/login_page.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:capstone_story_app/screens/auth/kakao_extra_info_page.dart';
import 'package:capstone_story_app/services/auth_service.dart';

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => RootDeciderState();
}

class RootDeciderState extends State<RootDecider> {
  static RootDeciderState? _instance;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  bool _checked = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _appLinks = AppLinks();
    _listenToLinkStream();
    _checkLogin();
  }

  void _listenToLinkStream() {
    _sub = _appLinks.uriLinkStream.listen((uri) {
      print("🔗 딥링크 수신: $uri");
      _handleUri(uri);
    }, onError: (err) {
      print('❌ 링크 스트림 오류: $err');
    });
  }

  /// 로그인 중에는 pause(), 그 외엔 resume() 으로 제어
  static void setLinkListening(bool enable) {
    final sub = _instance?._sub;
    if (sub != null) {
      enable ? sub.resume() : sub.pause();
    }
  }

  Future<void> _handleUri(Uri? uri) async {
    if (uri == null) return;
    if (uri.scheme == "myapp" && uri.host == "auth") {
      final isNew = uri.queryParameters["is_new_user"] == "true";
      if (isNew) {
        final kakaoId = uri.queryParameters["kakao_id"]!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KakaoExtraInfoPage(kakaoId: kakaoId),
          ),
        );
        return;
      }
      final token = uri.queryParameters["token"];
      if (token != null) {
        await AuthService.saveToken(token);
        setState(() {
          _loggedIn = true;
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

  Future<void> _checkLogin() async {
    final token = await AuthService.getToken();
    setState(() {
      _loggedIn = token != null;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const SplashScreen();
    return _loggedIn ? const HomeScreen() : const LoginPage();
  }
}
