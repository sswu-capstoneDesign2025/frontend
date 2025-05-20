// 📁 lib/screens/health/health_screen.dart

import 'package:flutter/material.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  bool diabetesAlarm = true;
  bool stretchingAlarm = true;
  bool medicineAlarm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFF8DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('말벗', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Icon(Icons.alarm, size: 28),
          SizedBox(width: 16),
          Icon(Icons.account_circle, size: 28),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("나이: 72세", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("성별: 남성", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("지역: 대구", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("관심", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: const [
                        Chip(label: Text('고혈압'), backgroundColor: Color(0xFFD7F3C7)),
                        Chip(label: Text('관절염'), backgroundColor: Color(0xFFD7F3C7)),
                        Chip(label: Text('당뇨'), backgroundColor: Color(0xFFD7F3C7)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildAlarmTile(
                    "당뇨 알람", "매일 오전 9시, 오후 ...", diabetesAlarm, (val) {
                  setState(() => diabetesAlarm = val);
                }),
                _buildAlarmTile("스트레칭 알람", "매일 오전 9시", stretchingAlarm, (val) {
                  setState(() => stretchingAlarm = val);
                }),
                _buildAlarmTile("약 알람", "매일 오전 8시, 오후 ...", medicineAlarm, (val) {
                  setState(() => medicineAlarm = val);
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlarmTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

