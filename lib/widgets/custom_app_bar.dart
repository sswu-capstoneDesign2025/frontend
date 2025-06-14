// 상단 AppBar
import 'package:capstone_story_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:capstone_story_app/screens/user_profile/my_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final String? titleText;
  final bool isHome;

  const CustomAppBar({
    this.backgroundColor = Colors.white,
    this.isHome = false,
    this.titleText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 90, // 높이 증가 (기본은 56)
      leading: isHome
          ? null
          : Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.home, color: Colors.black, size: 45),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
              );
            },
          ),
        ),
      ),
      title: titleText != null
          ? Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          titleText!,
          style: const TextStyle(
            fontFamily: 'BaedalJua',
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      )
          : null,
      actions: [
        Center(
          child: IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black, size: 44),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}