import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/services/notification_service.dart';

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
