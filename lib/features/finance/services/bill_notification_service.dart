import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';

/// Service for managing bill-related notifications.
/// Handles scheduling reminders for recurring bills.
class BillNotificationService {
  BillNotificationService(this._notificationService);

  final NotificationService _notificationService;

  /// Generate a unique notification ID for a bill.
  /// Format: 200000 + billId
  static int _generateNotificationId(Id billId) {
    return 200000 + billId;
  }

  /// Schedule a reminder notification for a bill due date.
  /// Schedules reminderDaysBefore days before due date.
  Future<void> scheduleBillReminder(RecurringBill bill) async {
    if (bill.id == null || !bill.isActive) {
      if (kDebugMode) {
        debugPrint('Cannot schedule reminder: bill has no ID or is not active');
      }
      return;
    }

    // Cancel existing notification for this bill
    await cancelBillReminder(bill.id!);

    final notificationId = _generateNotificationId(bill.id!);
    final reminderDate =
        bill.nextDueDate.subtract(Duration(days: bill.reminderDaysBefore));

    // Only schedule if reminder date is in the future
    if (reminderDate.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('Reminder date has passed, not scheduling');
      }
      return;
    }

    final payload = jsonEncode({
      'type': 'bill',
      'id': bill.id,
      'billId': bill.id,
    });

    // Create action buttons
    final actions = [
      NotificationAction(
        id: 'mark_paid_${bill.id}',
        label: 'Mark Paid',
        payload: 'bill|${bill.id}|mark_paid',
      ),
      NotificationAction(
        id: 'snooze_${bill.id}',
        label: 'Snooze',
        payload: 'bill|${bill.id}|snooze',
      ),
    ];

    // Schedule notification
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: 'Bill Reminder: ${bill.name}',
      body:
          'Your bill of \$${bill.amount.toStringAsFixed(2)} is due on ${bill.nextDueDate.day}/${bill.nextDueDate.month}/${bill.nextDueDate.year}',
      payload: payload,
      scheduledDate: reminderDate,
      actions: actions,
    );

    if (kDebugMode) {
      debugPrint('Scheduled reminder for bill ${bill.id}');
    }
  }

  /// Cancel reminder notification for a bill.
  Future<void> cancelBillReminder(Id billId) async {
    final notificationId = _generateNotificationId(billId);
    await _notificationService.cancelNotification(notificationId);

    if (kDebugMode) {
      debugPrint('Cancelled reminder for bill $billId');
    }
  }

  /// Reschedule reminders for all active bills.
  Future<void> rescheduleAllBillReminders(List<RecurringBill> bills) async {
    for (final bill in bills) {
      if (bill.id != null && bill.isActive) {
        await scheduleBillReminder(bill);
      }
    }
  }
}
