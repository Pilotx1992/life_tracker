import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for creating and managing linked reminders
class LinkedReminderService {
  LinkedReminderService(this._ref);

  final Ref _ref;

  /// Auto-create reminders for medication times
  Future<void> createMedicationReminders(Medication medication) async {
    if (medication.id == null) return;

    try {
      final reminderNotifier = _ref.read(reminderListProvider.notifier);

      for (var i = 0; i < medication.times.length; i++) {
        final timeDateTime = medication.times[i];
        final time = TimeOfDay.fromDateTime(timeDateTime);

        // Create reminder for each medication time
        final reminder = Reminder(
          title: 'Take ${medication.name}',
          description: 'Dosage: ${medication.dosage}',
          dateTime: _getNextMedicationTime(time, medication.startDate),
          priority: 'High',
          isRecurring: true,
          recurringPattern: 'Daily',
          linkedType: 'medication',
          linkedId: medication.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await reminderNotifier.addReminder(reminder);
      }

      if (kDebugMode) {
        debugPrint(
          'Created ${medication.times.length} reminders for medication ${medication.id}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating medication reminders: $e');
      }
    }
  }

  /// Auto-create reminder for bill due date
  Future<void> createBillReminder(RecurringBill bill) async {
    if (bill.id == null || !bill.isActive) return;

    try {
      final reminderNotifier = _ref.read(reminderListProvider.notifier);

      // Create reminder for bill due date
      final reminder = Reminder(
        title: 'Pay ${bill.name}',
        description: 'Amount: \$${bill.amount.toStringAsFixed(2)}',
        dateTime: bill.nextDueDate,
        priority: 'High',
        isRecurring: bill.isActive,
        recurringPattern: bill.frequency,
        linkedType: 'bill',
        linkedId: bill.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await reminderNotifier.addReminder(reminder);

      if (kDebugMode) {
        debugPrint('Created reminder for bill ${bill.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating bill reminder: $e');
      }
    }
  }

  /// Delete reminders linked to a specific item
  Future<void> deleteLinkedReminders(String linkedType, Id linkedId) async {
    try {
      final reminderNotifier = _ref.read(reminderListProvider.notifier);
      final allReminders = _ref.read(upcomingRemindersProvider);

      final linkedReminders = allReminders
          .where((r) => r.linkedType == linkedType && r.linkedId == linkedId)
          .toList();

      for (final reminder in linkedReminders) {
        if (reminder.id != null) {
          await reminderNotifier.deleteReminder(reminder.id!);
        }
      }

      if (kDebugMode) {
        debugPrint(
          'Deleted ${linkedReminders.length} reminders for $linkedType:$linkedId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting linked reminders: $e');
      }
    }
  }

  /// Update reminders when linked item changes
  Future<void> updateMedicationReminders(Medication medication) async {
    // Delete old reminders and create new ones
    if (medication.id != null) {
      await deleteLinkedReminders('medication', medication.id!);
      // Only create reminders if medication is still active (no end date or end date in future)
      final now = DateTime.now();
      if (medication.endDate == null || medication.endDate!.isAfter(now)) {
        await createMedicationReminders(medication);
      }
    }
  }

  /// Update reminders when bill changes
  Future<void> updateBillReminder(RecurringBill bill) async {
    // Delete old reminders and create new ones
    if (bill.id != null) {
      await deleteLinkedReminders('bill', bill.id!);
      if (bill.isActive) {
        await createBillReminder(bill);
      }
    }
  }

  DateTime _getNextMedicationTime(TimeOfDay time, DateTime? startDate) {
    final now = DateTime.now();
    final start = startDate ?? now;

    var nextTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    // If start date is in the future, use that
    if (start.isAfter(now)) {
      nextTime = DateTime(
        start.year,
        start.month,
        start.day,
        time.hour,
        time.minute,
      );
    }

    return nextTime;
  }
}
