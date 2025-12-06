// Note: avoid importing dart:io here to prevent unused import warnings
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Simple NotificationService scaffold.
/// - Initializes flutter_local_notifications
/// - Provides scheduling/cancel APIs
/// - Requests runtime permissions where applicable
class NotificationService {
  NotificationService.internal([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService.internal();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    try {
      tzdata.initializeTimeZones();
    } catch (e) {
      // timezones may already be initialized; ignore
      if (kDebugMode) debugPrint('tz init error: $e');
    }

    // Android initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS initialization
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

  final initSettings = const InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      // App-level tap handler (optional, to be wired by app)
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Placeholder: handle notification taps / actions
        if (kDebugMode) debugPrint('Notification tapped: ${response.payload}');
      },
    );

    _initialized = true;
  }

  /// Request notification permissions (Android 13+ and iOS).
  Future<bool> requestPermissions() async {
    // Use permission_handler for cross-platform notification permission request.
    // This avoids referencing platform-specific plugin types which can cause
    // analyzer issues across different flutter_local_notifications versions.
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Schedule a one-off notification at [scheduledDate] (local time).
  Future<void> scheduleNotification({
    required int id,
    required String title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
    List<NotificationAction>? actions,
  }) async {
    await initialize();

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          channelDescription: 'General notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          actions: actions
              ?.map((a) => AndroidNotificationAction(a.id, a.label))
              .toList(),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Use androidScheduleMode instead of the deprecated androidAllowWhileIdle.
      // exactAllowWhileIdle preserves the previous behavior of firing at the exact time
      // even if the device is idle. Adjust if you prefer inexact / low-power behavior.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule a daily notification at a specific local time (hour/minute).
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    String? body,
    String? payload,
    required int hour,
    required int minute,
    List<NotificationAction>? actions,
  }) async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily',
          channelDescription: 'Daily notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          actions: actions
              ?.map((a) => AndroidNotificationAction(a.id, a.label))
              .toList(),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}

