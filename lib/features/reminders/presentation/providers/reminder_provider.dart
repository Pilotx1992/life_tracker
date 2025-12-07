import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/domain/usecases/add_reminder.dart';
import 'package:life_tracker/features/reminders/domain/usecases/calculate_next_occurrence.dart';
import 'package:life_tracker/features/reminders/domain/usecases/delete_reminder.dart';
import 'package:life_tracker/features/reminders/domain/usecases/get_reminders.dart';
import 'package:life_tracker/features/reminders/domain/usecases/mark_reminder_completed.dart';
import 'package:life_tracker/features/reminders/domain/usecases/update_reminder.dart';
import 'package:life_tracker/features/reminders/reminders_providers.dart';
import 'package:life_tracker/features/reminders/services/reminder_notification_service.dart';
import 'package:life_tracker/features/reminders/services/alarm_service.dart';
import 'package:life_tracker/features/reminders/services/alarm_sound_service.dart';
import 'package:life_tracker/core/providers/notification_provider.dart';

// ============================================================================
// USE CASE PROVIDERS (Dependency Injection)
// ============================================================================

final addReminderUseCaseProvider =
    Provider((ref) => AddReminder(ref.read(reminderRepositoryProvider)));

final getRemindersUseCaseProvider =
    Provider((ref) => GetReminders(ref.read(reminderRepositoryProvider)));

final updateReminderUseCaseProvider =
    Provider((ref) => UpdateReminder(ref.read(reminderRepositoryProvider)));

final deleteReminderUseCaseProvider =
    Provider((ref) => DeleteReminder(ref.read(reminderRepositoryProvider)));

final markReminderCompletedUseCaseProvider = Provider(
  (ref) => MarkReminderCompleted(ref.read(reminderRepositoryProvider)),
);

final calculateNextOccurrenceUseCaseProvider =
    Provider((ref) => CalculateNextOccurrence());

// ============================================================================
// ALARM & NOTIFICATION SERVICE PROVIDERS
// ============================================================================

final alarmSoundServiceProvider = Provider<AlarmSoundService>((ref) {
  return AlarmSoundService();
});

final alarmServiceProvider = Provider<AlarmService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final soundService = ref.read(alarmSoundServiceProvider);
  return AlarmService(
    notificationService: notificationService,
    soundService: soundService,
  );
});

final reminderNotificationServiceProvider =
    Provider<ReminderNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final alarmService = ref.read(alarmServiceProvider);
  return ReminderNotificationService(
    notificationService,
    alarmService: alarmService,
  );
});

// ============================================================================
// MAIN REMINDER LIST PROVIDER (Single Source of Truth)
// ============================================================================

/// Main provider that holds all reminders.
/// This is the SINGLE SOURCE OF TRUTH for reminder data.
class ReminderListNotifier extends AsyncNotifier<List<Reminder>> {
  @override
  Future<List<Reminder>> build() async {
    return _fetchAllReminders();
  }

  Future<List<Reminder>> _fetchAllReminders() async {
    final getReminders = ref.read(getRemindersUseCaseProvider);
    final result = await getReminders(NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (reminders) => reminders,
    );
  }

  /// Reload all reminders from database
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAllReminders());
  }

  /// Add a new reminder
  Future<bool> addReminder(Reminder reminder) async {
    try {
      final addReminderUseCase = ref.read(addReminderUseCaseProvider);
      final notificationService = ref.read(reminderNotificationServiceProvider);

      final result = await addReminderUseCase(reminder);

      return await result.fold(
        (failure) {
          if (kDebugMode)
            debugPrint('Failed to add reminder: ${failure.message}');
          return false;
        },
        (id) async {
          // Schedule notification for the new reminder
          try {
            await notificationService.scheduleReminderNotification(
              reminder.copyWith(id: id),
            );
          } catch (e) {
            if (kDebugMode) debugPrint('Failed to schedule notification: $e');
          }

          // Refresh the list to include the new reminder
          await refresh();
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding reminder: $e');
      return false;
    }
  }

  /// Update an existing reminder
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      final updateReminderUseCase = ref.read(updateReminderUseCaseProvider);
      final notificationService = ref.read(reminderNotificationServiceProvider);

      final result = await updateReminderUseCase(reminder);

      return await result.fold(
        (failure) {
          if (kDebugMode)
            debugPrint('Failed to update reminder: ${failure.message}');
          return false;
        },
        (success) async {
          // Update notification
          if (reminder.id != null) {
            try {
              if (reminder.isCompleted) {
                await notificationService
                    .cancelReminderNotification(reminder.id!);
              } else {
                await notificationService
                    .scheduleReminderNotification(reminder);
              }
            } catch (e) {
              if (kDebugMode) debugPrint('Failed to update notification: $e');
            }
          }

          await refresh();
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating reminder: $e');
      return false;
    }
  }

  /// Delete a reminder by ID
  Future<bool> deleteReminder(Id id) async {
    try {
      final deleteReminderUseCase = ref.read(deleteReminderUseCaseProvider);
      final notificationService = ref.read(reminderNotificationServiceProvider);

      // Cancel notification first
      try {
        await notificationService.cancelReminderNotification(id);
      } catch (e) {
        if (kDebugMode) debugPrint('Error cancelling notification: $e');
      }

      // Delete from database
      final result = await deleteReminderUseCase(id);

      return await result.fold(
        (failure) {
          if (kDebugMode)
            debugPrint('Failed to delete reminder: ${failure.message}');
          return false;
        },
        (success) async {
          await refresh();
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting reminder: $e');
      return false;
    }
  }

  /// Mark a reminder as completed
  Future<bool> markAsCompleted(Id id) async {
    try {
      final markCompletedUseCase =
          ref.read(markReminderCompletedUseCaseProvider);
      final calculateNextOccurrence =
          ref.read(calculateNextOccurrenceUseCaseProvider);
      final notificationService = ref.read(reminderNotificationServiceProvider);

      // Get the current reminder before marking as completed
      final currentReminders = state.valueOrNull ?? [];
      final reminder = currentReminders.firstWhere(
        (r) => r.id == id,
        orElse: () => throw Exception('Reminder not found'),
      );

      // Mark as completed
      final result = await markCompletedUseCase(id);

      return await result.fold(
        (failure) {
          if (kDebugMode)
            debugPrint('Failed to mark completed: ${failure.message}');
          return false;
        },
        (success) async {
          // Cancel notification for completed reminder
          try {
            await notificationService.cancelReminderNotification(id);
          } catch (e) {
            if (kDebugMode) debugPrint('Error cancelling notification: $e');
          }

          // Handle recurring reminders - create next occurrence
          if (reminder.isRecurring && reminder.recurringPattern != null) {
            await _handleRecurringReminder(reminder, calculateNextOccurrence);
          }

          await refresh();
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error marking reminder as completed: $e');
      return false;
    }
  }

  /// Handle recurring reminder - create next occurrence
  Future<void> _handleRecurringReminder(
    Reminder reminder,
    CalculateNextOccurrence calculateNextOccurrence,
  ) async {
    final nextOccurrenceResult = await calculateNextOccurrence(
      CalculateNextOccurrenceParams(
        currentDateTime: reminder.dateTime,
        recurringPattern: reminder.recurringPattern!,
        recurringInterval: reminder.recurringInterval,
        recurringEndDate: reminder.recurringEndDate,
      ),
    );

    await nextOccurrenceResult.fold(
      (failure) async {
        if (kDebugMode)
          debugPrint('Failed to calculate next occurrence: ${failure.message}');
      },
      (nextOccurrence) async {
        // Check if next occurrence is within end date bounds
        if (reminder.recurringEndDate == null ||
            !nextOccurrence.isAfter(reminder.recurringEndDate!)) {
          // Calculate next-next occurrence for the new reminder
          final nextNextResult = await calculateNextOccurrence(
            CalculateNextOccurrenceParams(
              currentDateTime: nextOccurrence,
              recurringPattern: reminder.recurringPattern!,
              recurringInterval: reminder.recurringInterval,
              recurringEndDate: reminder.recurringEndDate,
            ),
          );

          final nextNextOccurrence = nextNextResult.fold((l) => null, (r) => r);

          // Create next occurrence reminder
          final nextReminder = reminder.copyWith(
            id: null,
            dateTime: nextOccurrence,
            isCompleted: false,
            nextOccurrence: nextNextOccurrence,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await addReminder(nextReminder);
        }
      },
    );
  }
}

/// Main provider - all reminders
final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<Reminder>>(
  ReminderListNotifier.new,
);

// ============================================================================
// DERIVED PROVIDERS (Pure Filtering - No Side Effects)
// ============================================================================

/// Upcoming reminders - filtered from main list
/// Shows non-completed reminders with dateTime in the future
final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(reminderListProvider);
  final reminders = remindersAsync.valueOrNull ?? [];

  final now = DateTime.now();

  return reminders
      .where((r) =>
          !r.isCompleted &&
          r.dateTime.isAfter(now.subtract(const Duration(seconds: 1))))
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
});

/// Completed reminders - filtered from main list
final completedRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(reminderListProvider);
  final reminders = remindersAsync.valueOrNull ?? [];

  return reminders.where((r) => r.isCompleted).toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Most recent first
});

// ============================================================================
// BACKWARD COMPATIBILITY ALIASES
// ============================================================================

/// Alias for backward compatibility with existing code
/// @deprecated Use reminderListProvider instead
final reminderNotifierProvider = reminderListProvider;
