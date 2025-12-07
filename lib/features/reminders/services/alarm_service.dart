import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/services/alarm_sound_service.dart';
import 'package:vibration/vibration.dart';

/// Service for managing alarm scheduling, ringing, and actions.
class AlarmService {
  final NotificationService _notificationService;
  final AlarmSoundService _soundService;
  final Map<Id, Timer> _activeAlarms = {};
  final Map<Id, bool> _isRinging = {};

  AlarmService({
    required NotificationService notificationService,
    required AlarmSoundService soundService,
  })  : _notificationService = notificationService,
        _soundService = soundService;

  /// Generate a unique notification ID for a reminder alarm.
  /// Format: 400000 + reminderId (to avoid clashes with other notifications)
  static int _generateAlarmNotificationId(Id reminderId) {
    return 400000 + reminderId;
  }

  /// Schedule an alarm for a reminder.
  Future<void> scheduleAlarm(Reminder reminder) async {
    if (reminder.id == null || !reminder.hasAlarm || reminder.isCompleted) {
      if (kDebugMode) {
        debugPrint(
          'Cannot schedule alarm: reminder has no ID, alarm disabled, or is completed',
        );
      }
      return;
    }

    // Cancel existing alarm for this reminder
    await cancelAlarm(reminder.id!);

    final notificationId = _generateAlarmNotificationId(reminder.id!);

    // Only schedule if reminder date is in the future
    if (reminder.dateTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('Reminder date has passed, not scheduling alarm');
      }
      return;
    }

    // Schedule notification with alarm channel
    await _notificationService.scheduleAlarmNotification(
      id: notificationId,
      title: reminder.title,
      body: reminder.description ?? 'Reminder: ${reminder.title}',
      scheduledDate: reminder.dateTime,
      reminderId: reminder.id!,
    );

    if (kDebugMode) {
      debugPrint(
        'Scheduled alarm for reminder ${reminder.id} on ${reminder.dateTime}',
      );
    }
  }

  /// Start ringing alarm (called when alarm time is reached).
  Future<void> startRinging(Reminder reminder) async {
    if (reminder.id == null) return;

    final reminderId = reminder.id!;
    if (_isRinging[reminderId] == true) {
      // Already ringing
      return;
    }

    _isRinging[reminderId] = true;

    // Start vibration if enabled
    if (reminder.vibrate) {
      _startVibration(reminderId);
    }

    // Start sound if alarm is enabled
    if (reminder.hasAlarm) {
      await _soundService.playAlarmSound(
        soundPath: reminder.alarmSound,
        repeatCount: reminder.repeatCount,
      );
    }

    if (kDebugMode) {
      debugPrint('Alarm started ringing for reminder $reminderId');
    }
  }

  /// Stop ringing alarm.
  Future<void> stopRinging(Id reminderId) async {
    if (_isRinging[reminderId] != true) {
      return;
    }

    _isRinging[reminderId] = false;

    // Stop vibration
    await _stopVibration(reminderId);

    // Stop sound
    await _soundService.stopAlarmSound();

    if (kDebugMode) {
      debugPrint('Alarm stopped ringing for reminder $reminderId');
    }
  }

  /// Dismiss alarm (stop ringing and mark as completed).
  Future<void> dismissAlarm(Id reminderId) async {
    await stopRinging(reminderId);
    await cancelAlarm(reminderId);
  }

  /// Snooze alarm (reschedule for later).
  Future<void> snoozeAlarm(Reminder reminder) async {
    if (reminder.id == null) return;

    await stopRinging(reminder.id!);

    // Calculate snooze time
    final snoozeTime = DateTime.now().add(
      Duration(minutes: reminder.snoozeDuration),
    );

    // Create a temporary reminder for the snooze
    final snoozedReminder = reminder.copyWith(
      dateTime: snoozeTime,
      updatedAt: DateTime.now(),
    );

    // Reschedule the alarm
    await scheduleAlarm(snoozedReminder);

    if (kDebugMode) {
      debugPrint(
        'Alarm snoozed for reminder ${reminder.id} until $snoozeTime',
      );
    }
  }

  /// Cancel alarm for a reminder.
  Future<void> cancelAlarm(Id reminderId) async {
    await stopRinging(reminderId);

    final notificationId = _generateAlarmNotificationId(reminderId);
    await _notificationService.cancelNotification(notificationId);

    // Cancel any active timers
    _activeAlarms[reminderId]?.cancel();
    _activeAlarms.remove(reminderId);

    if (kDebugMode) {
      debugPrint('Cancelled alarm for reminder $reminderId');
    }
  }

  /// Start vibration for an alarm.
  void _startVibration(Id reminderId) {
    // Cancel existing vibration timer if any
    _activeAlarms[reminderId]?.cancel();

    // Start continuous vibration
    // Vibration pattern: vibrate for 500ms, pause for 200ms, repeat
    final timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      Vibration.vibrate(duration: 500);
    });

    _activeAlarms[reminderId] = timer;
  }

  /// Stop vibration for an alarm.
  Future<void> _stopVibration(Id reminderId) async {
    _activeAlarms[reminderId]?.cancel();
    _activeAlarms.remove(reminderId);
    await Vibration.cancel();
  }

  /// Check if alarm is currently ringing.
  bool isRinging(Id reminderId) {
    return _isRinging[reminderId] == true;
  }

  /// Dispose resources.
  void dispose() {
    for (final timer in _activeAlarms.values) {
      timer.cancel();
    }
    _activeAlarms.clear();
    _isRinging.clear();
    _soundService.dispose();
  }
}

