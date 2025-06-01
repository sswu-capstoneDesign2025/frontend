import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:capstone_story_app/services/notification_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<_AlarmItem> alarms = [
    _AlarmItem(title: "당뇨 알람", time: TimeOfDay(hour: 9, minute: 0), enabled: true),
    _AlarmItem(title: "스트레칭 알람", time: TimeOfDay(hour: 9, minute: 0), enabled: true),
    _AlarmItem(title: "약 알람", time: TimeOfDay(hour: 8, minute: 0), enabled: false),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    for (var alarm in alarms) {
      if (alarm.enabled) NotificationService.scheduleAlarm(alarm);
    }
  }

  void _addAlarm() async {
    final result = await showDialog<_AlarmItem>(
      context: context,
      builder: (context) => _AlarmDialog(),
    );

    if (result != null) {
      setState(() => alarms.add(result));
      NotificationService.scheduleAlarm(result);
    }
  }

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
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("나이: 72세", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("성별: 남성", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("지역: 대구", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  VerticalDivider(
                    color: Colors.black26,
                    thickness: 1,
                    width: 32,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("관심", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Column(
                          children: [
                            Chip(label: Text('고혈압'), backgroundColor: Color(0xFFD7F3C7)),
                            SizedBox(height: 6),
                            Chip(label: Text('관절염'), backgroundColor: Color(0xFFD7F3C7)),
                            SizedBox(height: 6),
                            Chip(label: Text('당뇨'), backgroundColor: Color(0xFFD7F3C7)),
                          ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return _buildAlarmTile(alarm, (val) {
                  setState(() => alarm.enabled = val);
                  if (val) {
                    NotificationService.scheduleAlarm(alarm);
                  } else {
                    NotificationService.cancelAlarm(alarm.id);
                  }
                });
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlarmTile(_AlarmItem alarm, Function(bool) onChanged) {
    final formattedTime = alarm.time.format(context);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black12),
      ),
      child: ListTile(
        title: Text(alarm.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("매일 $formattedTime"),
        trailing: Switch(value: alarm.enabled, onChanged: onChanged),
      ),
    );
  }
}

class _AlarmItem {
  final int id;
  final String title;
  final TimeOfDay time;
  bool enabled;

  _AlarmItem({required this.title, required this.time, this.enabled = true})
      : id = DateTime.now().millisecondsSinceEpoch;
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
              Navigator.pop(context, _AlarmItem(title: title, time: _selectedTime));
            }
          },
          child: const Text("추가"),
        )
      ],
    );
  }
}
