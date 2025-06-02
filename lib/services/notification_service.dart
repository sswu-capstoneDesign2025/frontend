// 📁 notification_service.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:capstone_story_app/main.dart'; // navigatorKey 사용을 위해 필요
import 'package:capstone_story_app/screens/health/alarm_popup.dart'; // AlarmPopup import

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'alarm_channel',
    '알람',
    description: '일정 시간에 알람을 보냅니다',
    importance: Importance.max,
  );

  /// 초기화
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // 알림 권한 요청
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload ?? '시간 정보 없음';

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AlarmPopup(
              time: payload,
              message: '알람 시간입니다!',
            ),
          ),
        );
      },
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// 알람 예약
  static Future<void> scheduleAlarm(dynamic alarm) async {
    final int id = alarm.id as int;
    final String title = alarm.title as String;
    final TimeOfDay time = alarm.time as TimeOfDay;

    final now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduled = tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      scheduled.hour,
      scheduled.minute,
    );

    final String formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      '알람 시간입니다!',
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          '알람',
          channelDescription: '일정 시간에 알람을 보냅니다',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: formattedTime, // 🔥 여기에 시간 전달
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
