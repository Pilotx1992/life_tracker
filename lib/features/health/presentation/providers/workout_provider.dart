import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/domain/entities/workout_entry.dart';

/// Provider for Workout data
/// TODO: Implement full repository pattern when data layer is ready
final workoutListProvider = Provider<List<WorkoutEntry>>((ref) {
  // Mock data for now - will be replaced with real data source
  return [];
});

/// Provider for today's workouts
final todayWorkoutsProvider = Provider<List<WorkoutEntry>>((ref) {
  final workouts = ref.watch(workoutListProvider);
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  return workouts.where((workout) {
    return workout.date.isAfter(todayStart) && workout.date.isBefore(todayEnd);
  }).toList();
});

/// Provider for total calories burned today
final todayCaloriesBurnedProvider = Provider<double>((ref) {
  final todayWorkouts = ref.watch(todayWorkoutsProvider);
  return todayWorkouts.fold<double>(
    0.0,
    (sum, workout) => sum + (workout.calories ?? 0.0),
  );
});

/// Provider for total distance today
final todayDistanceProvider = Provider<double>((ref) {
  final todayWorkouts = ref.watch(todayWorkoutsProvider);
  return todayWorkouts.fold<double>(
    0.0,
    (sum, workout) => sum + (workout.distance ?? 0.0),
  );
});
