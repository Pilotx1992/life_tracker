import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/features/health/data/models/medication_intake_model.dart';
import 'package:life_tracker/features/health/data/models/medication_model.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/features/reminders/data/models/reminder_model.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';

/// Handles notification actions (taps and action buttons).
/// Processes medication-related actions like "Taken" and "Snooze".
class NotificationActionHandler {
  NotificationActionHandler(this._ref);

  final Ref _ref;

  /// Handle notification response (tap or action button).
  Future<void> handleNotificationResponse(NotificationResponse response) async {
    if (kDebugMode) {
      debugPrint(
        'Notification response: actionId=${response.actionId}, payload=${response.payload}',
      );
    }

    final payload = response.payload;
    if (payload == null) return;

    // Parse payload format: "action|id|extra"
    // Examples:
    // - "medication|123|0" - medication notification tap
    // - "medication_taken|123|0" - "Taken" button
    // - "medication_snooze|123|0" - "Snooze" button
    // - "reminder|456" - reminder notification tap
    // - "reminder|456|done" - "Done" button
    // - "reminder|456|snooze" - "Snooze" button
    final parts = payload.split('|');
    if (parts.length < 2) return;

    final action = parts[0];
    final idStr = parts[1];
    final extra = parts.length > 2 ? parts[2] : '';

    try {
      if (action == 'medication' ||
          action == 'medication_taken' ||
          action == 'medication_snooze') {
        final medicationId = Id.parse(idStr);
        final timeIndex = int.parse(extra.isEmpty ? '0' : extra);

        if (action == 'medication_taken') {
          await _handleMedicationTaken(medicationId, timeIndex);
        } else if (action == 'medication_snooze') {
          await _handleMedicationSnooze(medicationId, timeIndex);
        } else if (action == 'medication') {
          // Notification tap - could navigate to medication detail screen
          if (kDebugMode) {
            debugPrint('Medication notification tapped: $medicationId');
          }
        }
      } else if (action == 'reminder' ||
          action == 'reminder_done' ||
          action == 'reminder_snooze') {
        final reminderId = Id.parse(idStr);

        if (extra == 'done' || action == 'reminder_done') {
          await _handleReminderDone(reminderId);
        } else if (extra == 'snooze' || action == 'reminder_snooze') {
          await _handleReminderSnooze(reminderId);
        } else if (action == 'reminder') {
          // Notification tap - could navigate to reminder detail screen
          if (kDebugMode) {
            debugPrint('Reminder notification tapped: $reminderId');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle "Taken" action - mark medication intake as taken.
  Future<void> _handleMedicationTaken(Id medicationId, int timeIndex) async {
    try {
      final database = await DatabaseService.instance.database;

      // Find the medication intake for this medication and time
      final intakes = await database.medicationIntakeModels
          .filter()
          .medicationIdEqualTo(medicationId)
          .findAll();

      // Find intake for the scheduled time (today)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get the medication to find the correct time
      final medication = await database.medicationModels.get(medicationId);
      if (medication == null || timeIndex >= medication.times.length) {
        if (kDebugMode) {
          debugPrint('Medication not found or invalid time index');
        }
        return;
      }

      final targetTime = medication.times[timeIndex];

      MedicationIntakeModel? targetIntake;
      for (final intake in intakes) {
        final scheduledDate = intake.scheduledTime;
        if (scheduledDate.year == today.year &&
            scheduledDate.month == today.month &&
            scheduledDate.day == today.day &&
            scheduledDate.hour == targetTime.hour &&
            scheduledDate.minute == targetTime.minute) {
          targetIntake = intake;
          break;
        }
      }

      if (targetIntake != null) {
        // Convert to entity and mark as taken
        final intakeEntity = targetIntake.toEntity();
        final notifier = _ref.read(medicationNotifierProvider.notifier);
        await notifier.markMedicationAsTaken(intakeEntity);

        if (kDebugMode) {
          debugPrint('Marked medication $medicationId intake as taken');
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            'Could not find medication intake for medication $medicationId at time index $timeIndex',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error handling medication taken: $e');
      }
    }
  }

  /// Handle "Snooze" action - reschedule notification for 10 minutes later.
  Future<void> _handleMedicationSnooze(Id medicationId, int timeIndex) async {
    try {
      final database = await DatabaseService.instance.database;
      final medication = await database.medicationModels.get(medicationId);

      if (medication == null) {
        if (kDebugMode) {
          debugPrint('Medication $medicationId not found for snooze');
        }
        return;
      }

      if (timeIndex >= medication.times.length) {
        if (kDebugMode) {
          debugPrint(
            'Invalid time index $timeIndex for medication $medicationId',
          );
        }
        return;
      }

      // Get the scheduled time
      final scheduledTime = medication.times[timeIndex];
      final now = DateTime.now();

      // Calculate next occurrence (today if time hasn't passed, otherwise tomorrow)
      var nextTime = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      if (nextTime.isBefore(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }

      // Snooze for 10 minutes
      final snoozedTime = nextTime.add(const Duration(minutes: 10));

      // Find the intake and update it
      final intakes = await database.medicationIntakeModels
          .filter()
          .medicationIdEqualTo(medicationId)
          .findAll();

      final today = DateTime(now.year, now.month, now.day);
      MedicationIntakeModel? targetIntake;

      for (final intake in intakes) {
        final scheduledDate = intake.scheduledTime;
        if (scheduledDate.year == today.year &&
            scheduledDate.month == today.month &&
            scheduledDate.day == today.day &&
            scheduledDate.hour == scheduledTime.hour &&
            scheduledDate.minute == scheduledTime.minute) {
          targetIntake = intake;
          break;
        }
      }

      if (targetIntake != null) {
        final intakeEntity = targetIntake.toEntity();
        final notifier = _ref.read(medicationNotifierProvider.notifier);
        await notifier.snoozeMedicationIntake(intakeEntity, snoozedTime);

        if (kDebugMode) {
          debugPrint(
            'Snoozed medication $medicationId to ${snoozedTime.toString()}',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('Could not find medication intake to snooze');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error handling medication snooze: $e');
      }
    }
  }

  /// Handle "Done" action - mark reminder as completed.
  Future<void> _handleReminderDone(Id reminderId) async {
    try {
      await _ref
          .read(reminderNotifierProvider.notifier)
          .markReminderAsCompleted(reminderId);
      if (kDebugMode) {
        debugPrint('Reminder marked as done: $reminderId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking reminder as done: $e');
      }
    }
  }

  /// Handle "Snooze" action - reschedule reminder for 10 minutes later.
  Future<void> _handleReminderSnooze(Id reminderId) async {
    try {
      // Get the reminder from database
      final database = await DatabaseService.instance.database;
      final reminderModel = await database.reminderModels.get(reminderId);

      if (reminderModel == null) {
        if (kDebugMode) {
          debugPrint('Reminder $reminderId not found for snooze');
        }
        return;
      }

      final reminder = reminderModel.toEntity();

      // Reschedule for 10 minutes later
      final snoozedDateTime =
          reminder.dateTime.add(const Duration(minutes: 10));
      final updatedReminder = reminder.copyWith(
        dateTime: snoozedDateTime,
        updatedAt: DateTime.now(),
      );

      await _ref
          .read(reminderNotifierProvider.notifier)
          .updateReminderEntry(updatedReminder);

      if (kDebugMode) {
        debugPrint('Reminder snoozed: $reminderId until $snoozedDateTime');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error snoozing reminder: $e');
      }
    }
  }
}
