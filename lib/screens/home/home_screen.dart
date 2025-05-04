// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // TODO: index에 따라 다른 페이지로 이동하거나, 내용 바꾸기
    // 예: Navigator.pushNamed(context, '/news') 등
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2B5720), width: 2),
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
              onTap: () {
                // TODO: 마이크/바루 기능 실행
              },
              child: Image.asset(
                'assets/images/baru.png',
                width: 320,
                height: 320,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
