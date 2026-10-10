import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/app_state.dart';
import '../core/strings.dart';

/// Local reminders before tracked dates. Everything stays on the phone.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Reminder slots: days-before → slot number used in the notification id.
  static const _slots = {60: 1, 30: 2, 1: 3};

  /// Reminders need the phone (Android/iOS); the web preview skips them.
  static bool get supported => !kIsWeb;

  Future<void> init() async {
    if (!supported) return;
    tzdata.initializeTimeZones();
    // The app is for people living in Italy.
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
  }

  Future<void> requestPermission() async {
    if (!supported) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleFor(TrackedDate date, Set<int> offsets) async {
    if (!supported) return;
    await cancelFor(date);
    await requestPermission();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'dates',
        'Carta Facile',
        channelDescription: 'Reminders for documents and appointments',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final entry in _slots.entries) {
      final daysBefore = entry.key;
      if (!offsets.contains(daysBefore)) continue;

      final when = tz.TZDateTime(tz.local, date.date.year, date.date.month,
              date.date.day, 9) // 9:00 in the morning
          .subtract(Duration(days: daysBefore));
      if (when.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _plugin.zonedSchedule(
        date.id * 10 + entry.value,
        date.title,
        '${tr('in_days')} $daysBefore ${tr('days')} — ${tr('reminder_body')}',
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() async {
    if (!supported) return;
    await _plugin.cancelAll();
  }

  Future<void> cancelFor(TrackedDate date) async {
    if (!supported) return;
    for (final slot in _slots.values) {
      await _plugin.cancel(date.id * 10 + slot);
    }
  }
}
