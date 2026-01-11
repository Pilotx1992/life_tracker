import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/services/alarm_service.dart';

/// Service for managing reminder-related notifications.
/// Handles scheduling notifications for standalone reminders.
/// If reminder has alarm enabled, uses AlarmService instead.
///
/// Uses DEFENSIVE PROGRAMMING with comprehensive error handling and logging.
class ReminderNotificationService {
  ReminderNotificationService(
    this._notificationService, {
    AlarmService? alarmService,
  }) : _alarmService = alarmService;

  final NotificationService _notificationService;
  final AlarmService? _alarmService;

  /// Generate a unique notification ID for a reminder.
  /// Format: 300000 + reminderId (to avoid clashes with other notifications)
  static int _generateNotificationId(Id reminderId) {
    return 300000 + reminderId;
  }

  /// Schedule a notification for a reminder.
  /// If reminder has alarm enabled, uses AlarmService.
  /// Returns true if scheduling was successful.
  Future<bool> scheduleReminderNotification(Reminder reminder) async {
    try {
      // Defensive: Validate reminder
      if (reminder.id == null) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ ReminderNotification: Cannot schedule - reminder has no ID');
        }
        return false;
      }

      if (reminder.isCompleted) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ ReminderNotification: Cannot schedule - reminder ${reminder.id} is completed');
        }
        return false;
      }

      // Cancel existing notification for this reminder first
      await cancelReminderNotification(reminder.id!);

      // Defensive: Check if date is in the future
      final now = DateTime.now();
      if (reminder.dateTime.isBefore(now)) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ ReminderNotification: Cannot schedule - date has passed');
          debugPrint('   Reminder date: ${reminder.dateTime}');
          debugPrint('   Current time: $now');
        }
        return false;
      }

      // Use AlarmService if alarm is enabled
      if (reminder.hasAlarm && _alarmService != null) {
        try {
          await _alarmService.scheduleAlarm(reminder);
          if (kDebugMode) {
            debugPrint(
                '⏰ ReminderNotification: Scheduled ALARM for reminder ${reminder.id}');
            debugPrint('   Title: ${reminder.title}');
            debugPrint('   DateTime: ${reminder.dateTime}');
            debugPrint('   Vibrate: ${reminder.vibrate}');
            debugPrint('   Snooze: ${reminder.snoozeDuration} min');
          }
          return true;
        } catch (e, stack) {
          if (kDebugMode) {
            debugPrint('❌ ReminderNotification: Failed to schedule alarm: $e');
            debugPrint('Stack: $stack');
          }
          // Fall through to regular notification as backup
        }
      }

      // Regular notification
      final notificationId = _generateNotificationId(reminder.id!);

      final payload = jsonEncode({
        'type': 'reminder',
        'id': reminder.id,
        'reminderId': reminder.id,
      });

      // Create action buttons
      final actions = [
        NotificationAction(
          id: 'done_${reminder.id}',
          label: 'Done',
          payload: 'reminder|${reminder.id}|done',
        ),
        NotificationAction(
          id: 'snooze_${reminder.id}',
          label: 'Snooze',
          payload: 'reminder|${reminder.id}|snooze',
        ),
      ];

      if (kDebugMode) {
        debugPrint('🔔 ReminderNotification: Scheduling notification:');
        debugPrint('   ID: $notificationId');
        debugPrint('   Reminder ID: ${reminder.id}');
        debugPrint('   Title: ${reminder.title}');
        debugPrint('   DateTime: ${reminder.dateTime}');
        debugPrint('   Has Alarm: ${reminder.hasAlarm}');
      }

      // Schedule notification
      final success = await _notificationService.scheduleNotification(
        id: notificationId,
        title: reminder.title,
        body: reminder.description ?? 'Reminder: ${reminder.title}',
        payload: payload,
        scheduledDate: reminder.dateTime,
        actions: actions,
      );

      if (success) {
        if (kDebugMode) {
          debugPrint(
              '✅ ReminderNotification: Notification scheduled successfully');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ ReminderNotification: Failed to schedule notification');
        }
      }

      return success;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ ReminderNotification: Exception while scheduling: $e');
        debugPrint('Stack: $stack');
      }
      return false;
    }
  }

  /// Cancel notification for a reminder.
  /// Also cancels alarm if it exists.
  Future<void> cancelReminderNotification(Id reminderId) async {
    try {
      // Cancel alarm if it exists
      if (_alarmService != null) {
        try {
          await _alarmService.cancelAlarm(reminderId);
          if (kDebugMode) {
            debugPrint(
                '🚫 ReminderNotification: Cancelled alarm for reminder $reminderId');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ ReminderNotification: Failed to cancel alarm: $e');
          }
        }
      }

      // Cancel regular notification
      final notificationId = _generateNotificationId(reminderId);
      await _notificationService.cancelNotification(notificationId);

      if (kDebugMode) {
        debugPrint(
            '🚫 ReminderNotification: Cancelled notification for reminder $reminderId');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ ReminderNotification: Exception while cancelling: $e');
        debugPrint('Stack: $stack');
      }
    }
  }

  /// Schedule notifications for all active reminders.
  /// Returns the count of successfully scheduled notifications.
  Future<int> rescheduleAllReminderNotifications(
      List<Reminder> reminders) async {
    int successCount = 0;
    int failCount = 0;

    if (kDebugMode) {
      debugPrint(
          '🔄 ReminderNotification: Rescheduling ${reminders.length} reminders...');
    }

    for (final reminder in reminders) {
      if (reminder.id != null && !reminder.isCompleted) {
        final success = await scheduleReminderNotification(reminder);
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }
    }

    if (kDebugMode) {
      debugPrint('✅ ReminderNotification: Rescheduled $successCount reminders');
      if (failCount > 0) {
        debugPrint(
            '⚠️ ReminderNotification: Failed to reschedule $failCount reminders');
      }
    }

    return successCount;
  }

  /// Schedule next occurrence for a recurring reminder.
  Future<bool> scheduleNextRecurringReminder(Reminder reminder) async {
    if (reminder.nextOccurrence == null) {
      if (kDebugMode) {
        debugPrint(
            '⚠️ ReminderNotification: No next occurrence for reminder ${reminder.id}');
      }
      return false;
    }

    final nextReminder = reminder.copyWith(
      dateTime: reminder.nextOccurrence!,
      isCompleted: false,
      updatedAt: DateTime.now(),
    );

    return await scheduleReminderNotification(nextReminder);
  }

  /// Debug: Print all pending notifications
  Future<void> debugPrintPendingNotifications() async {
    if (kDebugMode) {
      await _notificationService.getPendingNotifications();
    }
  }
}
