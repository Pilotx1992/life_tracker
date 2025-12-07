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

  // Initialize the service
  service.initialize();

  // Return the stream
  return service.todayStepsStream;
});

/// Provider for the current step count (synchronous access)
final currentPedometerStepsProvider = Provider<int>((ref) {
  final asyncSteps = ref.watch(todayStepsFromPedometerProvider);
  return asyncSteps.when(
    data: (steps) => steps,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
