// 상단 AppBar

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAlarmTap;
  final VoidCallback? onProfileTap;
  final Color backgroundColor;
  final String? titleText;

  const CustomAppBar({
    this.onAlarmTap,
    this.onProfileTap,
    this.backgroundColor = Colors.white, // 기본은 흰색
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
      leading: Navigator.of(context).canPop()
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,
      title: titleText != null
          ? Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 10.0),
        child: Text(
          titleText!,
          style: const TextStyle(
            fontFamily: 'BaedalJua',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      )
          : null,
      actions: [
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
