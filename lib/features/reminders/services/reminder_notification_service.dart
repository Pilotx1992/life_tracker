import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';

/// Service for managing reminder-related notifications.
/// Handles scheduling notifications for standalone reminders.
class ReminderNotificationService {
  ReminderNotificationService(this._notificationService);

  final NotificationService _notificationService;

  /// Generate a unique notification ID for a reminder.
  /// Format: 300000 + reminderId (to avoid clashes with other notifications)
  static int _generateNotificationId(Id reminderId) {
    return 300000 + reminderId;
  }

  /// Schedule a notification for a reminder.
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (reminder.id == null || reminder.isCompleted) {
      if (kDebugMode) {
        debugPrint(
          'Cannot schedule notification: reminder has no ID or is completed',
        );
      }
      return;
    }

    // Cancel existing notification for this reminder
    await cancelReminderNotification(reminder.id!);

    final notificationId = _generateNotificationId(reminder.id!);

    // Only schedule if reminder date is in the future
    if (reminder.dateTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('Reminder date has passed, not scheduling');
      }
      return;
    }

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

    // Schedule notification
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: reminder.title,
      body: reminder.description ?? 'Reminder: ${reminder.title}',
      payload: payload,
      scheduledDate: reminder.dateTime,
      actions: actions,
    );

    if (kDebugMode) {
      debugPrint(
        'Scheduled notification for reminder ${reminder.id} on ${reminder.dateTime}',
      );
    }
  }

  /// Cancel notification for a reminder.
  Future<void> cancelReminderNotification(Id reminderId) async {
    final notificationId = _generateNotificationId(reminderId);
    await _notificationService.cancelNotification(notificationId);

    if (kDebugMode) {
      debugPrint('Cancelled notification for reminder $reminderId');
    }
  }

  /// Schedule notifications for all active reminders.
  Future<void> rescheduleAllReminderNotifications(
    List<Reminder> reminders,
  ) async {
    for (final reminder in reminders) {
      if (reminder.id != null && !reminder.isCompleted) {
        await scheduleReminderNotification(reminder);
      }
    }
  }

  /// Schedule next occurrence for a recurring reminder.
  Future<void> scheduleNextRecurringReminder(Reminder reminder) async {
    if (reminder.nextOccurrence != null) {
      final nextReminder = reminder.copyWith(
        dateTime: reminder.nextOccurrence!,
        isCompleted: false,
        updatedAt: DateTime.now(),
      );
      await scheduleReminderNotification(nextReminder);
    }
  }
}
