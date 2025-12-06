import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';

/// A provider that asynchronously initializes the Isar database
/// and exposes the Isar instance.
final isarProvider = FutureProvider<Isar>((ref) async {
  return await DatabaseService.instance.database;
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
    // Watch the isarProvider to trigger the initialization.
    final appStartup = ref.watch(isarProvider);

    return appStartup.when(
      // When initialization is complete, show the main app.
      data: (_) => onLoaded(context),
      // While initializing, show a loading screen.
      // You can replace this with your splash screen widget.
      loading: () => const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: CircularProgressIndicator()),
      ),
      // If initialization fails, show an error screen.
      error: (e, st) => Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Text('Error initializing app: $e')),
      ),
    );
  }
}