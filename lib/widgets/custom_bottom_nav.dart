//하단 BottomNavigationBar

import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNav({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // 물결 애니메이션 제거
          //splashColor: Colors.transparent,       // 터치 색상 제거
          //highlightColor: Colors.transparent,    // 눌림 효과 제거
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFE3FFCD),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article, size: 32),
              label: '뉴스',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 34),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups, size: 32),
              label: '수다',
            ),
          ],
        ),
      ),
    );
  }
}
