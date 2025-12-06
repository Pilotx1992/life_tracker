import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/domain/usecases/add_reminder.dart';
import 'package:life_tracker/features/reminders/domain/usecases/calculate_next_occurrence.dart';
import 'package:life_tracker/features/reminders/domain/usecases/delete_reminder.dart';
import 'package:life_tracker/features/reminders/domain/usecases/get_completed_reminders.dart';
import 'package:life_tracker/features/reminders/domain/usecases/get_reminders.dart';
import 'package:life_tracker/features/reminders/domain/usecases/get_upcoming_reminders.dart';
import 'package:life_tracker/features/reminders/domain/usecases/mark_reminder_completed.dart';
import 'package:life_tracker/features/reminders/domain/usecases/update_reminder.dart';
import 'package:life_tracker/features/reminders/reminders_providers.dart';
import 'package:life_tracker/features/reminders/services/reminder_notification_service.dart';
import 'package:life_tracker/core/providers/notification_provider.dart';

// Providers for use cases (dependency injection)
final addReminderUseCaseProvider =
    Provider((ref) => AddReminder(ref.read(reminderRepositoryProvider)));
final getRemindersUseCaseProvider =
    Provider((ref) => GetReminders(ref.read(reminderRepositoryProvider)));
final getUpcomingRemindersUseCaseProvider = Provider(
  (ref) => GetUpcomingReminders(ref.read(reminderRepositoryProvider)),
);
final getCompletedRemindersUseCaseProvider = Provider(
  (ref) => GetCompletedReminders(ref.read(reminderRepositoryProvider)),
);
final updateReminderUseCaseProvider =
    Provider((ref) => UpdateReminder(ref.read(reminderRepositoryProvider)));
final deleteReminderUseCaseProvider =
    Provider((ref) => DeleteReminder(ref.read(reminderRepositoryProvider)));
final markReminderCompletedUseCaseProvider = Provider(
  (ref) => MarkReminderCompleted(ref.read(reminderRepositoryProvider)),
);
final calculateNextOccurrenceUseCaseProvider =
    Provider((ref) => CalculateNextOccurrence());

// Notification service provider
final reminderNotificationServiceProvider = Provider<ReminderNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return ReminderNotificationService(notificationService);
});

// StateNotifier for managing reminder-related state
class ReminderNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final AddReminder _addReminder;
  final GetReminders _getReminders;
  final GetUpcomingReminders _getUpcomingReminders;
  final GetCompletedReminders _getCompletedReminders;
  final UpdateReminder _updateReminder;
  final DeleteReminder _deleteReminder;
  final MarkReminderCompleted _markCompleted;
  final CalculateNextOccurrence _calculateNextOccurrence;
  final ReminderNotificationService? _notificationService;

  ReminderNotifier({
    required AddReminder addReminder,
    required GetReminders getReminders,
    required GetUpcomingReminders getUpcomingReminders,
    required GetCompletedReminders getCompletedReminders,
    required UpdateReminder updateReminder,
    required DeleteReminder deleteReminder,
    required MarkReminderCompleted markCompleted,
    required CalculateNextOccurrence calculateNextOccurrence,
    ReminderNotificationService? notificationService,
  })  : _addReminder = addReminder,
        _getReminders = getReminders,
        _getUpcomingReminders = getUpcomingReminders,
        _getCompletedReminders = getCompletedReminders,
        _updateReminder = updateReminder,
        _deleteReminder = deleteReminder,
        _markCompleted = markCompleted,
        _calculateNextOccurrence = calculateNextOccurrence,
        _notificationService = notificationService,
        super(const AsyncValue.loading());

  Future<void> loadReminders() async {
    state = const AsyncValue.loading();
    final result = await _getReminders(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (reminders) => AsyncValue.data(reminders),
    );
  }

  Future<List<Reminder>> getUpcomingRemindersList() async {
    final result = await _getUpcomingReminders(NoParams());
    return result.fold((l) => [], (r) => r);
  }

  Future<List<Reminder>> getCompletedRemindersList() async {
    final result = await _getCompletedReminders(NoParams());
    return result.fold((l) => [], (r) => r);
  }

  Future<void> addReminderEntry(Reminder reminder) async {
    final result = await _addReminder(reminder);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) async {
        // Schedule notification
        if (_notificationService != null) {
          await _notificationService.scheduleReminderNotification(
            reminder.copyWith(id: id),
          );
        }
        loadReminders(); // Reload reminders after adding
      },
    );
  }

  Future<void> updateReminderEntry(Reminder reminder) async {
    final result = await _updateReminder(reminder);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Update notification
        if (_notificationService != null && reminder.id != null) {
          if (reminder.isCompleted) {
            await _notificationService.cancelReminderNotification(reminder.id!);
          } else {
            await _notificationService.scheduleReminderNotification(reminder);
          }
        }
        loadReminders(); // Reload reminders after updating
      },
    );
  }

  Future<void> deleteReminderEntry(Id id) async {
    final result = await _deleteReminder(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Cancel notification
        if (_notificationService != null) {
          await _notificationService.cancelReminderNotification(id);
        }
        loadReminders(); // Reload reminders after deleting
      },
    );
  }

  Future<void> markReminderAsCompleted(Id id) async {
    final result = await _markCompleted(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // If it's a recurring reminder, calculate next occurrence
        final currentReminders = state.value ?? [];
        final reminder = currentReminders.firstWhere((r) => r.id == id);

        if (reminder.isRecurring && reminder.recurringPattern != null) {
          final nextOccurrenceResult = await _calculateNextOccurrence(
            CalculateNextOccurrenceParams(
              currentDateTime: reminder.dateTime,
              recurringPattern: reminder.recurringPattern!,
              recurringInterval: reminder.recurringInterval,
              recurringEndDate: reminder.recurringEndDate,
            ),
          );

          nextOccurrenceResult.fold(
            (failure) => state = AsyncValue.error(failure, StackTrace.current),
            (nextOccurrence) async {
              // Check if next occurrence exceeds end date
              if (reminder.recurringEndDate == null ||
                  nextOccurrence.isBefore(reminder.recurringEndDate!) ||
                  nextOccurrence.isAtSameMomentAs(reminder.recurringEndDate!)) {
                // Calculate next occurrence for the new reminder
                final nextNextOccurrenceResult = await _calculateNextOccurrence(
                  CalculateNextOccurrenceParams(
                    currentDateTime: nextOccurrence,
                    recurringPattern: reminder.recurringPattern!,
                    recurringInterval: reminder.recurringInterval,
                    recurringEndDate: reminder.recurringEndDate,
                  ),
                );

                final nextNextOccurrence = nextNextOccurrenceResult.fold(
                  (l) => null,
                  (r) => r,
                );

                // Create next occurrence
                final nextReminder = reminder.copyWith(
                  id: null, // New reminder
                  dateTime: nextOccurrence,
                  isCompleted: false,
                  nextOccurrence: nextNextOccurrence,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await addReminderEntry(nextReminder);
              }
            },
          );
        }

        loadReminders(); // Reload reminders after marking completed
      },
    );
  }
}

final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, AsyncValue<List<Reminder>>>((ref) {
  final notifier = ReminderNotifier(
    addReminder: ref.read(addReminderUseCaseProvider),
    getReminders: ref.read(getRemindersUseCaseProvider),
    getUpcomingReminders: ref.read(getUpcomingRemindersUseCaseProvider),
    getCompletedReminders: ref.read(getCompletedRemindersUseCaseProvider),
    updateReminder: ref.read(updateReminderUseCaseProvider),
    deleteReminder: ref.read(deleteReminderUseCaseProvider),
    markCompleted: ref.read(markReminderCompletedUseCaseProvider),
    calculateNextOccurrence: ref.read(calculateNextOccurrenceUseCaseProvider),
    notificationService: ref.read(reminderNotificationServiceProvider),
  );
  // Load reminders after the notifier is created, not in constructor
  Future.microtask(() => notifier.loadReminders());
  return notifier;
});

final upcomingRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  return ref
      .watch(reminderNotifierProvider.notifier)
      .getUpcomingRemindersList();
});

final completedRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  return ref
      .watch(reminderNotifierProvider.notifier)
      .getCompletedRemindersList();
});
