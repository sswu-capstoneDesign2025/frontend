import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class CustomLayout extends StatelessWidget {
  final String? appBarTitle;
  final bool isHome;
  final Widget child;
  final Color backgroundColor;

  const CustomLayout({
    super.key,
    this.appBarTitle,
    required this.child,
    this.isHome = false,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: CustomAppBar(
        backgroundColor: backgroundColor,
        titleText: appBarTitle,
        isHome: isHome,
      ),
      body: child,
    );
  }
}
