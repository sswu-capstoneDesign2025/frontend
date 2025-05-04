// 상단 AppBar

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAlarmTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({this.onAlarmTap, this.onProfileTap, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Padding(
        padding: EdgeInsets.only(left: 8.0, top: 10.0),
        child: Text(
          '말벗',
          style: TextStyle(
            fontFamily: 'BaedalJua',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: IconButton(
            icon: const Icon(Icons.alarm, color: Colors.black, size: 37),
            onPressed: onAlarmTap,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black, size: 40),
            onPressed: onProfileTap,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
