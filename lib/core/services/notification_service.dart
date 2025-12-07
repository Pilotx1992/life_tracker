// Note: avoid importing dart:io here to prevent unused import warnings
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

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
  bool _permissionGranted = false;

  /// Check if notification service is ready
  bool get isReady => _initialized && _permissionGranted;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tzdata.initializeTimeZones();

      // Get device timezone and set it
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        if (kDebugMode) {
          debugPrint('📍 Timezone set to: $timeZoneName');
        }
      } catch (e) {
        // Fallback to UTC if timezone detection fails
        if (kDebugMode) {
          debugPrint('⚠️ Failed to get timezone, using UTC: $e');
        }
        tz.setLocalLocation(tz.UTC);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Timezone initialization error: $e');
      }
    }

    try {
      // Android initialization
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS / macOS initialization
      const iosInit = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final initSettings = const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      final success = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          if (kDebugMode) {
            debugPrint('🔔 Notification tapped: ${response.payload}');
          }
        },
      );

      _initialized = success ?? false;

      if (kDebugMode) {
        debugPrint('✅ NotificationService initialized: $_initialized');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ NotificationService initialization failed: $e');
        debugPrint('Stack: $stack');
      }
      _initialized = false;
    }
  }

  /// Request notification permissions (Android 13+ and iOS).
  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      _permissionGranted = status.isGranted;

      if (kDebugMode) {
        debugPrint(
            '🔔 Notification permission: $_permissionGranted (status: $status)');
      }

      // Also request exact alarm permission for Android 12+
      try {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
        if (kDebugMode) {
          debugPrint('⏰ Exact alarm permission: ${exactAlarmStatus.isGranted}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Exact alarm permission request failed: $e');
        }
      }

      // Request battery optimization exemption for background alarms
      try {
        final batteryStatus =
            await Permission.ignoreBatteryOptimizations.request();
        if (kDebugMode) {
          debugPrint(
              '🔋 Battery optimization exemption: ${batteryStatus.isGranted}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Battery optimization request failed: $e');
        }
      }

      return _permissionGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Permission request failed: $e');
      }
      return false;
    }
  }

  /// Schedule a one-off notification at [scheduledDate] (local time).
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
    List<NotificationAction>? actions,
  }) async {
    try {
      await initialize();

      // Defensive: Check if date is in the future
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Cannot schedule notification in the past: $scheduledDate (now: $now)');
        }
        return false;
      }

      // Convert to TZDateTime
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      if (kDebugMode) {
        debugPrint('📅 Scheduling notification:');
        debugPrint('   ID: $id');
        debugPrint('   Title: $title');
        debugPrint('   Scheduled: $scheduledDate');
        debugPrint('   TZ Scheduled: $tzDate');
        debugPrint('   TZ Local: ${tz.local}');
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            channelDescription: 'Reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            actions: actions
                ?.map((a) => AndroidNotificationAction(a.id, a.label))
                .toList(),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      if (kDebugMode) {
        debugPrint('✅ Notification scheduled successfully: ID=$id');
      }

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Failed to schedule notification: $e');
        debugPrint('Stack: $stack');
      }
      return false;
    }
  }

  /// Schedule a daily notification at a specific local time (hour/minute).
  Future<bool> scheduleDailyNotification({
    required int id,
    required String title,
    String? body,
    String? payload,
    required int hour,
    required int minute,
    List<NotificationAction>? actions,
  }) async {
    try {
      await initialize();

      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      if (kDebugMode) {
        debugPrint('📅 Scheduling daily notification: ID=$id at $hour:$minute');
      }

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
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            actions: actions
                ?.map((a) => AndroidNotificationAction(a.id, a.label))
                .toList(),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      if (kDebugMode) {
        debugPrint('✅ Daily notification scheduled: ID=$id');
      }

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Failed to schedule daily notification: $e');
        debugPrint('Stack: $stack');
      }
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      if (kDebugMode) {
        debugPrint('🚫 Cancelled notification: ID=$id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cancel notification: $e');
      }
    }
  }

  /// Schedule an alarm notification with high importance.
  Future<bool> scheduleAlarmNotification({
    required int id,
    required String title,
    String? body,
    required DateTime scheduledDate,
    required int reminderId,
    List<NotificationAction>? actions,
  }) async {
    try {
      await initialize();

      // Defensive: Check if date is in the future
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Cannot schedule alarm in the past: $scheduledDate (now: $now)');
        }
        return false;
      }

      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      final payload = 'alarm|$reminderId';

      if (kDebugMode) {
        debugPrint('⏰ Scheduling ALARM:');
        debugPrint('   ID: $id');
        debugPrint('   Title: $title');
        debugPrint('   Scheduled: $scheduledDate');
        debugPrint('   TZ Scheduled: $tzDate');
        debugPrint('   Reminder ID: $reminderId');
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel',
            'Alarms',
            channelDescription: 'Alarm notifications with sound and vibration',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            actions: actions
                ?.map((a) => AndroidNotificationAction(a.id, a.label))
                .toList(),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      if (kDebugMode) {
        debugPrint('✅ ALARM scheduled successfully: ID=$id');
      }

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Failed to schedule alarm: $e');
        debugPrint('Stack: $stack');
      }
      return false;
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      if (kDebugMode) {
        debugPrint('🚫 Cancelled all notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cancel all notifications: $e');
      }
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      if (kDebugMode) {
        debugPrint('📋 Pending notifications: ${pending.length}');
        for (final p in pending) {
          debugPrint('   - ID: ${p.id}, Title: ${p.title}');
        }
      }
      return pending;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to get pending notifications: $e');
      }
      return [];
    }
  }

  /// Show an immediate notification (for testing)
  Future<bool> showImmediateNotification({
    required int id,
    required String title,
    String? body,
    String? payload,
  }) async {
    try {
      await initialize();

      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );

      if (kDebugMode) {
        debugPrint('✅ Immediate notification shown: ID=$id');
      }

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Failed to show immediate notification: $e');
        debugPrint('Stack: $stack');
      }
      return false;
    }
  }
}
