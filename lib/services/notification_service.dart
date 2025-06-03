import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:capstone_story_app/main.dart';
import 'package:capstone_story_app/screens/health/alarm_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'alarm_channel',
    '알람',
    description: '일정 시간에 알람을 보냅니다',
    importance: Importance.max,
  );

  /// 알림 초기화
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    // 권한 요청
    if (Platform.isAndroid) {
      final plugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.requestExactAlarmsPermission();
      await plugin?.requestNotificationsPermission();
    }

    // 알림 클릭 시 동작 설정
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload ?? '';
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => AlarmPopup(time: payload, message: '알람 시간입니다!'),
        ));
      },
    );

    // 알람 채널 생성
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// 알람 예약
  static Future<void> scheduleAlarm(Map<String, dynamic> alarm) async {
    final int id = alarm['id'];
    final String title = alarm['title'];
    final TimeOfDay time = TimeOfDay(
      hour: alarm['hour'],
      minute: alarm['minute'],
    );

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
      payload: formattedTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 알람 취소
  static Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// 알람 목록 SharedPreferences 저장
  static Future<void> saveAlarms(List<Map<String, dynamic>> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(alarms);
    await prefs.setString('alarms', jsonStr);
  }

  /// 알람 목록 SharedPreferences 로딩
  static Future<List<Map<String, dynamic>>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('alarms');
    if (jsonStr == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
  }
}
