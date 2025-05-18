// lib/widgets/custom_layout.dart
import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_nav.dart';
import 'package:capstone_story_app/screens/health/health_screen.dart';


class CustomLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Widget body;

  const CustomLayout({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onAlarmTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HealthScreen(),
            ),
          );
        },
        onProfileTap: () {
          // TODO: 내 정보 화면 이동
        },
      ),
      body: body,
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
