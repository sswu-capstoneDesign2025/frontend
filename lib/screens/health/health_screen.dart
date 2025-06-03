import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:capstone_story_app/services/notification_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<Map<String, dynamic>> alarms = [];

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
    return Scaffold(
      backgroundColor: const Color(0xFFCFF8DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('말벗', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          final time = TimeOfDay(hour: alarm['hour'], minute: alarm['minute']);
          final formattedTime = time.format(context);

          return Card(
            child: ListTile(
              title: Text(alarm['title']),
              subtitle: Text("매일 $formattedTime"),
              trailing: Switch(
                value: alarm['enabled'],
                onChanged: (val) => _toggleAlarm(index, val),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
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