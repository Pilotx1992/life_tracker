import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:life_tracker/core/providers/pedometer_provider.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
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

/// A provider that initializes the pedometer service.
final pedometerInitProvider = FutureProvider<void>((ref) async {
  // Wait for database first (pedometer uses SharedPreferences, not Isar, but good practice)
  await ref.watch(isarProvider.future);

  // Initialize pedometer service
  final pedometerService = ref.read(pedometerServiceProvider);
  await pedometerService.initialize();

  if (kDebugMode) {
    debugPrint('✅ Pedometer service initialized');
  }
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

/// A provider that reschedules all active bill notifications on app startup.
/// This ensures bill reminders work after app restart or device reboot.
final billRescheduleProvider = FutureProvider<int>((ref) async {
  // Wait for notification service to be ready
  await ref.watch(notificationInitProvider.future);

  try {
    // Get bill notification service
    final billNotificationService = ref.read(billNotificationServiceProvider);

    // Get all bills
    final billsAsync = ref.read(billNotifierProvider);

    return await billsAsync.when(
      data: (bills) async {
        // Filter to only active bills with future due dates
        final now = DateTime.now();
        final activeBills = bills
            .where(
              (b) =>
                  b.isActive &&
                  !b.isFullyPaid &&
                  b.nextDueDate.isAfter(now),
            )
            .toList();

        if (kDebugMode) {
          debugPrint(
            '🔄 Rescheduling ${activeBills.length} active bill reminders...',
          );
        }

        // Reschedule all active bills
        await billNotificationService.rescheduleAllBillReminders(activeBills);

        if (kDebugMode) {
          debugPrint(
            '✅ Successfully rescheduled ${activeBills.length} bill notifications',
          );
        }

        return activeBills.length;
      },
      loading: () async {
        if (kDebugMode) {
          debugPrint('⏳ Bills still loading...');
        }
        return 0;
      },
      error: (error, stack) async {
        if (kDebugMode) {
          debugPrint('❌ Failed to get bills for reschedule: $error');
        }
        return 0;
      },
    );
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('❌ Error rescheduling bills: $e');
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
    // Watch providers to trigger initialization.
    final appStartup = ref.watch(isarProvider);
    final notificationInit = ref.watch(notificationInitProvider);
    final pedometerInit = ref.watch(pedometerInitProvider);
    // Also trigger reminder and bill reschedule (don't wait for them)
    ref.watch(reminderRescheduleProvider);
    ref.watch(billRescheduleProvider);

    // Combine all initialization statuses
    final combinedStatus = appStartup.when(
      data: (_) => notificationInit.when(
        data: (_) => pedometerInit.when(
          data: (_) => 'loaded',
          loading: () => 'loading',
          error: (e, st) => 'error:$e',
        ),
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
