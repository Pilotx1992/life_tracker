import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';

/// Service for managing debt-related notifications.
/// Handles scheduling reminders for debt due dates.
class DebtNotificationService {
  DebtNotificationService(this._notificationService);

  final NotificationService _notificationService;

  /// Generate a unique notification ID for a debt.
  /// Format: 100000 + debtId
  static int _generateNotificationId(Id debtId) {
    return 100000 + debtId;
  }

  /// Schedule a reminder notification for a debt due date.
  /// Schedules 1 day before due date.
  Future<void> scheduleDebtReminder(Debt debt) async {
    if (debt.id == null || debt.isPaid) {
      if (kDebugMode) {
        debugPrint(
          'Cannot schedule reminder: debt has no ID or is already paid',
        );
      }
      return;
    }

    // Cancel existing notification for this debt
    await cancelDebtReminder(debt.id!);

    final notificationId = _generateNotificationId(debt.id!);
    final reminderDate = debt.dueDate.subtract(const Duration(days: 1));

    // Only schedule if reminder date is in the future
    if (reminderDate.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('Reminder date has passed, not scheduling');
      }
      return;
    }

    // Create action buttons
    final actions = [
      NotificationAction(
        id: 'view_debt_${debt.id}',
        label: 'View',
        payload: 'debt|${debt.id}',
      ),
    ];

    // Schedule notification
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Debt Reminder',
      body:
          '${debt.type == 'i_owe' ? 'You owe' : 'You are owed'} \$${debt.remainingAmount.toStringAsFixed(2)} to ${debt.person}. Due: ${debt.dueDate.day}/${debt.dueDate.month}/${debt.dueDate.year}',
      payload: 'debt|${debt.id}',
      scheduledDate: reminderDate,
      actions: actions,
    );

    if (kDebugMode) {
      debugPrint('Scheduled reminder for debt ${debt.id}');
    }
  }

  /// Cancel reminder notification for a debt.
  Future<void> cancelDebtReminder(Id debtId) async {
    final notificationId = _generateNotificationId(debtId);
    await _notificationService.cancelNotification(notificationId);

    if (kDebugMode) {
      debugPrint('Cancelled reminder for debt $debtId');
    }
  }

  /// Reschedule reminders for all active debts.
  Future<void> rescheduleAllDebtReminders(List<Debt> debts) async {
    for (final debt in debts) {
      if (debt.id != null && !debt.isPaid) {
        await scheduleDebtReminder(debt);
      }
    }
  }
}
