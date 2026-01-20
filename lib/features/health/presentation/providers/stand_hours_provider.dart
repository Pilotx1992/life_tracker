import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/data/repositories/stand_repository.dart';
import 'package:life_tracker/features/health/domain/usecases/track_stand_progress_usecase.dart';

// Ensure the UseCase is alive when the UI is active
// This provider keeps the logic running even if we only watch the repository stream
final standProgressLogicProvider = FutureProvider<void>((ref) async {
  // Just watching this provider ensures the UseCase initializes and listens
  await ref.watch(trackStandProgressUseCaseProvider.future);
});

/// Notifier providing the list of active stand hours for today
class StandHoursNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    // 1. Ensure logic is running
    await ref.watch(standProgressLogicProvider.future);

    // 2. Watch the repository for changes
    final repository = await ref.watch(standRepositoryProvider.future);

    // Subscribe to stream
    final stream = repository.watchTodayLog();

    // Yield values from stream
    await for (final log in stream) {
      state = AsyncData(log?.activeHours ?? []);
    }

    return []; // Should not reach here if stream is persistent
  }
}

// NOTE: AsyncNotifier with 'yield' pattern (Stream) usage via build() is slightly tricky.
// Better to use StreamNotifier or StreamProvider if just returning data.
// The user asked for a Notifier. A StreamProvider is the cleanest "Notifier" for this.

// Alternative: StreamProvider
final standHoursProvider = StreamProvider<List<int>>((ref) async* {
  // Ensure logic is running
  ref.watch(standProgressLogicProvider); // No need to await, just keep alive?
  // Actually FutureProvider (logic) might be loading.

  final repository = await ref.watch(standRepositoryProvider.future);

  await for (final log in repository.watchTodayLog()) {
    yield log?.activeHours ?? [];
  }
});
