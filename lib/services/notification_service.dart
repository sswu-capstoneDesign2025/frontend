import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// ✅ main.dart에서 await NotificationService.init() 사용 가능하게 함
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    // ✅ 시간대 초기화도 함께 수행
    tz.initializeTimeZones();
  }

  static Future<void> scheduleAlarm(dynamic alarm) async {
    final int id = alarm.id;
    final String title = alarm.title;
    final TimeOfDay time = alarm.time;

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).isBefore(now)
        ? DateTime(now.year, now.month, now.day + 1, time.hour, time.minute)
        : DateTime(now.year, now.month, now.day, time.hour, time.minute);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      '알람 시간입니다!',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          '알람',
          channelDescription: '일정 시간에 알람을 보냅니다',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay timeOfDay) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}

