import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/pedometer_service.dart';

/// Provider for PedometerService singleton
final pedometerServiceProvider = Provider<PedometerService>((ref) {
  final service = PedometerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for today's step count from pedometer (real-time stream)
final todayStepsFromPedometerProvider = StreamProvider<int>((ref) {
  final service = ref.watch(pedometerServiceProvider);

  // No need to initialize here - already initialized in app_startup.dart
  // Return the stream directly
  return service.todayStepsStream;
});

/// Provider for the current step count (synchronous access)
final currentPedometerStepsProvider = Provider<int>((ref) {
  final asyncSteps = ref.watch(todayStepsFromPedometerProvider);
  return asyncSteps.when(
    data: (steps) => steps,
    loading: () => ref.watch(pedometerServiceProvider).todaySteps,
    error: (_, __) => 0,
  );
});
