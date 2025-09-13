import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications and timezone
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _notificationsPlugin.initialize(settings);
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool? grantedNotificationPermission = await androidImplementation
        ?.requestNotificationsPermission();

    return grantedNotificationPermission ?? false;
  }

  /// Schedule daily notifications (3 per day)
  static Future<void> scheduleDailyNotifications({
    required bool enabled,
  }) async {
    try {
      // Request permissions first
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        return;
      }

      if (!enabled) {
        await _notificationsPlugin.cancelAll();
        return;
      }

      await _notificationsPlugin.cancelAll();

      final now = tz.TZDateTime.now(tz.local);

      List<TimeOfDay> times = [
        const TimeOfDay(hour: 8, minute: 0), // Morning
        const TimeOfDay(hour: 14, minute: 0), // Afternoon
        const TimeOfDay(hour: 19, minute: 0), // Evening
      ];

      List<List<String>> messages = [
        // Morning Messages (8:00 AM)
        [
          "The divine awaits your morning devotion 🌅",
          "Begin your day with sacred vibrations 🕉️",
          "Your soul craves its morning mantra 🙏",
          "Dawn brings fresh spiritual energy ✨",
          "Awaken your inner light with japa 🔆",
          "The universe whispers - time for prayer 🌸",
          "Your spiritual practice calls you 🛕",
          "Morning mantras create miracles 💫",
          "Divine grace flows through morning chants 🌺",
          "Start strong - your mantra awaits 💪",
        ],

        // Afternoon Messages (3:55 PM)
        [
          "Pause. Breathe. Chant. Reset your energy 🧘",
          "Your afternoon spiritual break is here ☀️",
          "Mid-day meditation restores your soul 🌼",
          "Time to realign with divine frequency 📿",
          "Sacred sounds heal your busy mind 🎵",
          "Your inner temple needs attention now 🏛️",
          "Refresh your spirit with holy names 💧",
          "Divine intervention in your hectic day ⚡",
          "Mantra magic transforms ordinary moments ✨",
          "Your soul's appointment with the divine 📅",
        ],

        // Evening Messages (7:00 PM)
        [
          "Sunset chanting purifies your day 🌅",
          "Evening mantras bring peaceful closure 🌙",
          "Reflect, chant, and release today's stress 🕯️",
          "Your evening devotion completes the circle 🔄",
          "Twilight whispers call for sacred sounds 🌆",
          "End your day in divine communion 🙏",
          "Evening japa prepares peaceful dreams 😴",
          "Sacred evening ritual awaits you 🌟",
          "Night falls - time for spiritual surrender 🌃",
          "Your day's final offering to the divine 🎭",
        ],
      ];

      final random = Random();

      for (int i = 0; i < times.length; i++) {
        final msgList = messages[i];
        final randomMessage = msgList[random.nextInt(msgList.length)];
        final scheduledTime = _nextInstanceOfTime(times[i]);

        await _notificationsPlugin.zonedSchedule(
          i, // unique ID for each notification
          "Japaura Reminder ⏰",
          randomMessage,
          scheduledTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'japaura_daily',
              'Daily Reminders',
              channelDescription: 'Daily mantra reminder notifications',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              showWhen: true,
              when: scheduledTime.millisecondsSinceEpoch,
              fullScreenIntent: false,
              category: AndroidNotificationCategory.reminder,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate next scheduled DateTime for TimeOfDay
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
