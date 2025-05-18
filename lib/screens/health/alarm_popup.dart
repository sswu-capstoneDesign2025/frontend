// 📁 lib/screens/health/alarm_popup.dart
import 'package:flutter/material.dart';

class AlarmPopup extends StatelessWidget {
  final String time;
  final String message;

  const AlarmPopup({super.key, required this.time, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm, size: 120, color: Colors.white),
            const SizedBox(height: 24),
            Text(time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                )),
          ],
        ),
      ),
    );
  }
}
