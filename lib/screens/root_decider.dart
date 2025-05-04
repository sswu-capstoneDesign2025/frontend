import 'package:flutter/material.dart';
import 'package:capstone_story_app/screens/splash/splash_screen.dart';
import 'package:capstone_story_app/screens/auth/login_page.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  bool _checked = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
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
