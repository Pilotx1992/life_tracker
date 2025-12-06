import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';

/// Service for managing medication-related notifications.
/// Handles scheduling, updating, and canceling medication reminders.
class MedicationNotificationService {
  MedicationNotificationService(this._notificationService);

  final NotificationService _notificationService;

  /// Generate a unique notification ID for a medication time.
  /// Format: medicationId * 1000 + timeIndex
  static int _generateNotificationId(Id medicationId, int timeIndex) {
    return (medicationId * 1000) + timeIndex;
  }

  /// Schedule notifications for all medication times.
  /// Cancels existing notifications for this medication first.
  Future<void> scheduleMedicationNotifications(Medication medication) async {
    if (medication.id == null) {
      if (kDebugMode) {
        debugPrint('Cannot schedule notifications: medication has no ID');
      }
      return;
    }

    // Cancel existing notifications for this medication
    await cancelMedicationNotifications(medication.id!);

    final now = DateTime.now();
    final startDate = medication.startDate;
    final endDate = medication.endDate;

    // Only schedule if medication is active (start date is today or in the past)
    if (startDate.isAfter(now)) {
      if (kDebugMode) {
        debugPrint('Medication starts in the future, not scheduling yet');
      }
      return;
    }

    // If medication has ended, don't schedule
    if (endDate != null && endDate.isBefore(now)) {
      if (kDebugMode) {
        debugPrint('Medication has ended, not scheduling');
      }
      return;
    }

    // Schedule notifications for each time
    for (int i = 0; i < medication.times.length; i++) {
      final time = medication.times[i];
      final notificationId = _generateNotificationId(medication.id!, i);

      // Create the scheduled date/time
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has passed today, schedule for tomorrow
      DateTime targetDateTime = scheduledDateTime;
      if (targetDateTime.isBefore(now)) {
        targetDateTime = targetDateTime.add(const Duration(days: 1));
      }

      // If medication has an end date, don't schedule beyond it
      if (endDate != null && targetDateTime.isAfter(endDate)) {
        continue;
      }

      // Create action buttons
      final actions = [
        NotificationAction(
          id: 'taken_${medication.id}_$i',
          label: 'Taken',
          payload: 'medication_taken|${medication.id}|$i',
        ),
        NotificationAction(
          id: 'snooze_${medication.id}_$i',
          label: 'Snooze',
          payload: 'medication_snooze|${medication.id}|$i',
        ),
      ];

      // Format time for display
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      // Schedule daily notification
      await _notificationService.scheduleDailyNotification(
        id: notificationId,
        title: 'Medication Reminder',
        body:
            'Time to take ${medication.name} (${medication.dosage}) at $timeString',
        payload: 'medication|${medication.id}|$i',
        hour: time.hour,
        minute: time.minute,
        actions: actions,
      );
    }

    if (kDebugMode) {
      debugPrint(
        'Scheduled ${medication.times.length} notifications for medication ${medication.id}',
      );
    }
  }

  /// Cancel all notifications for a medication.
  Future<void> cancelMedicationNotifications(Id medicationId) async {
    // Cancel notifications for up to 10 times (medicationId * 1000 + 0-9)
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(medicationId, i);
      await _notificationService.cancelNotification(notificationId);
    }

    if (kDebugMode) {
      debugPrint('Cancelled notifications for medication $medicationId');
    }
  }

  /// Reschedule all notifications for active medications.
  /// This is useful when the app starts or when notification permissions change.
  Future<void> rescheduleAllMedicationNotifications(
    List<Medication> medications,
  ) async {
    for (final medication in medications) {
      if (medication.id != null) {
        await scheduleMedicationNotifications(medication);
      }
    }
  }
}
