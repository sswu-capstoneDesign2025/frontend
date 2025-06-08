import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:capstone_story_app/services/notification_service.dart';
import 'package:capstone_story_app/widgets/custom_layout.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<Map<String, dynamic>> alarms = [];

  String age = '';
  String gender = '';
  String region = '';
  final List<String> interests = [];
  final TextEditingController interestController = TextEditingController();

  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    NotificationService.init().then((_) async {
      alarms = await NotificationService.loadAlarms();
      setState(() {});
      for (var alarm in alarms) {
        if (alarm['enabled'] == true) {
          NotificationService.scheduleAlarm(alarm);
        }
      }
    });
  }

  void _addAlarm() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AlarmDialog(),
    );

    if (result != null) {
      setState(() => alarms.add(result));
      NotificationService.scheduleAlarm(result);
      NotificationService.saveAlarms(alarms);
    }
  }

  void _toggleAlarm(int index, bool enabled) {
    setState(() => alarms[index]['enabled'] = enabled);
    NotificationService.saveAlarms(alarms);
    if (enabled) {
      NotificationService.scheduleAlarm(alarms[index]);
    } else {
      NotificationService.cancelAlarm(alarms[index]['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      appBarTitle: '건강 알림',
      backgroundColor: const Color(0xFFCFF8DC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isSaved
                    ? LayoutBuilder(
                  builder: (context, constraints) {
                    final lineHeight = interests.length * 36 > 90 ? interests.length * 36.0 : 90.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🧑 개인정보
                        Expanded(
                          flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // ← 수직 중앙 정렬
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("나이: ${age}세", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text("성별: $gender", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text("지역: $region", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            ],
                          ),
                        ),
                        ),

                        // 🟩 가운데 세로선
                        Container(
                          width: 1.5,
                          height: lineHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 12), // ← 좌우 간격
                          color: Colors.green.shade700,
                        ),

                        // ⭐ 관심사
                        Expanded(
                          flex: 2,
                        child: Align(
                    alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // ← 수직 중앙 정렬
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("관심", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 6),
                              ...interests.map((e) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.lightGreenAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(e, style: const TextStyle(fontSize: 14)),
                              )),
                            ],
                          ),
                        ),
                        ),
                      ],
                    );
                  },
                )

                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("나이", age, (val) => setState(() => age = val)),
                    _buildTextField("성별", gender, (val) => setState(() => gender = val)),
                    _buildTextField("지역", region, (val) => setState(() => region = val)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("관심:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: interestController,
                            decoration: const InputDecoration(hintText: "쉼표로 구분, 예: 고혈압, 당뇨"),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                final values = val.split(',');
                                final newInterests = values.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                print("✅ 입력된 관심사: $newInterests");
                                setState(() {
                                  interests.addAll(newInterests);  // 기존 방식대로 addAll 해야 누적됨
                                  interestController.clear();       // 이후에 clear
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: interests.map((e) => Chip(
                        label: Text(e),
                        backgroundColor: Colors.lightGreenAccent,
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (interestController.text.trim().isNotEmpty) {
                            final values = interestController.text.split(',');
                            final newInterests = values.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                            interests.addAll(newInterests);
                            interestController.clear();
                          }
                          print("✅ 저장됨: 나이=$age, 성별=$gender, 지역=$region, 관심사=$interests");
                          setState(() => isSaved = true);
                        },
                        child: const Text("저장"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ...alarms.map((alarm) {
              final time = TimeOfDay(hour: alarm['hour'], minute: alarm['minute']);
              final formattedTime = time.format(context);
              return Card(
                child: ListTile(
                  title: Text(alarm['title']),
                  subtitle: Text("매일 $formattedTime"),
                  trailing: Switch(
                    value: alarm['enabled'],
                    onChanged: (val) {
                      final index = alarms.indexOf(alarm);
                      _toggleAlarm(index, val);
                    },
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addAlarm,
                icon: const Icon(Icons.add),
                label: const Text("알람 추가"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }
}

class _AlarmDialog extends StatefulWidget {
  @override
  State<_AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<_AlarmDialog> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("알람 추가"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "알람 이름"),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("시간: "),
              TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                  }
                },
                child: Text(_selectedTime.format(context)),
              )
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isNotEmpty) {
              final alarm = {
                'id': DateTime.now().millisecondsSinceEpoch,
                'title': title,
                'hour': _selectedTime.hour,
                'minute': _selectedTime.minute,
                'enabled': true,
              };
              Navigator.pop(context, alarm);
            }
          },
          child: const Text("추가"),
        )
      ],
    );
  }
}
