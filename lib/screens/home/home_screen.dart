// 파일: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/auth/login_page.dart';
import 'package:capstone_story_app/screens/root_decider.dart';
import 'package:capstone_story_app/screens/home/news_screen.dart';
import 'package:capstone_story_app/screens/userstore/other_user_store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const NewsScreen(inputText: "오늘 뉴스 알려줘"),
        ),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OtherUserStoreScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 120),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF2B5720), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "바루를 눌러서 말해보세요",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B5720),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsScreen(inputText: "오늘 뉴스 알려줘"),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/baru.png',
                  width: 320,
                  height: 320,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await AuthService.clearToken();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RootDecider()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
