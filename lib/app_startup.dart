import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:life_tracker/core/usecases/usecase.dart';

/// A provider that asynchronously initializes the Isar database
/// and exposes the Isar instance.
final isarProvider = FutureProvider<Isar>((ref) async {
  return await DatabaseService.instance.database;
});

/// A provider that initializes the notification service.
final notificationInitProvider = FutureProvider<void>((ref) async {
  // Wait for database first
  await ref.watch(isarProvider.future);

  // Initialize notifications
  await NotificationService.instance.initialize();

  // Request notification permission
  await NotificationService.instance.requestPermissions();
});

/// A provider that reschedules all active reminder notifications on app startup.
/// This is critical for ensuring notifications work after app restart or device reboot.
final reminderRescheduleProvider = FutureProvider<int>((ref) async {
  // Wait for notification service to be ready
  await ref.watch(notificationInitProvider.future);

  try {
    // Get reminder notification service
    final notificationService = ref.read(reminderNotificationServiceProvider);

    // Get all reminders from repository
    final getRemindersUseCase = ref.read(getRemindersUseCaseProvider);
    final result = await getRemindersUseCase(NoParams());

    return await result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ Failed to get reminders for reschedule: ${failure.message}',
          );
        }
        return 0;
      },
      (reminders) async {
        // Filter to only non-completed reminders with future dates
        final now = DateTime.now();
        final activeReminders = reminders
            .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
            .toList();

        if (kDebugMode) {
          debugPrint(
            '🔄 Rescheduling ${activeReminders.length} active reminders...',
          );
        }

        // Reschedule all active reminders
        final count = await notificationService
            .rescheduleAllReminderNotifications(activeReminders);

        if (kDebugMode) {
          debugPrint(
            '✅ Successfully rescheduled $count reminder notifications',
          );
        }

        return count;
      },
    );
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('❌ Error rescheduling reminders: $e');
      debugPrint('Stack: $stack');
    }
    return 0;
  }
});

/// A widget that waits for app initialization to complete and then
/// shows the main app.
///
/// This is the new root widget of your application.
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key, required this.onLoaded});

  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both providers to trigger initialization.
    final appStartup = ref.watch(isarProvider);
    final notificationInit = ref.watch(notificationInitProvider);
    // Also trigger reminder reschedule (don't wait for it)
    ref.watch(reminderRescheduleProvider);

    // Combine both initialization statuses
    final combinedStatus = appStartup.when(
      data: (_) => notificationInit.when(
        data: (_) => 'loaded',
        loading: () => 'loading',
        error: (e, st) => 'error:$e',
      ),
      loading: () => 'loading',
      error: (e, st) => 'error:$e',
    );

    if (combinedStatus == 'loaded') {
      return onLoaded(context);
    } else if (combinedStatus == 'loading') {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      // Error state
      final errorMessage = combinedStatus.replaceFirst('error:', '');
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Text('Error initializing app: $errorMessage')),
      );
    }
  }
}
