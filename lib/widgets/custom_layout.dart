// lib/widgets/custom_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_app_bar.dart';
import 'package:capstone_story_app/screens/health/health_screen.dart';
import 'package:capstone_story_app/screens/user_profile/my_page.dart';

class CustomLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Widget body;
  final Color backgroundColor;
  final String? titleText;

  const CustomLayout({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.body,
    this.backgroundColor = Colors.white,
    this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(
          backgroundColor: backgroundColor,
          titleText: titleText,
          onAlarmTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthScreen()),
            );
          },
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPage()),
            );
          },
        ),
        body: SafeArea(child: body),
      ),
    );
  }
}
