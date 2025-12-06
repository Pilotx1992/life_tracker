import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/health_provider.dart';

/// Activity data model
class ActivityData {
  final double moveCurrent; // Active calories burned
  final double moveGoal; // Default: 270 kcal
  final double exerciseCurrent; // Exercise minutes
  final double exerciseGoal; // Default: 25 min
  final double standCurrent; // Stand hours
  final double standGoal; // Default: 12 hours
  final int steps;

  ActivityData({
    required this.moveCurrent,
    this.moveGoal = 270.0,
    required this.exerciseCurrent,
    this.exerciseGoal = 25.0,
    required this.standCurrent,
    this.standGoal = 12.0,
    required this.steps,
  });

  double get moveProgress => (moveCurrent / moveGoal).clamp(0.0, 1.0);
  double get exerciseProgress =>
      (exerciseCurrent / exerciseGoal).clamp(0.0, 1.0);
  double get standProgress => (standCurrent / standGoal).clamp(0.0, 1.0);
}

/// Provider for Activity Rings data
final activityDataProvider = Provider<ActivityData>((ref) {
  final healthState = ref.watch(healthConnectProvider);
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  // Calculate today's steps
  int todaySteps = 0;
  if (healthState.stepsData.isNotEmpty) {
    final todayStepsData = healthState.stepsData.where((step) {
      return step.date.isAfter(todayStart) && step.date.isBefore(todayEnd);
    }).toList();
    todaySteps = todayStepsData.fold<int>(
      0,
      (sum, step) => sum + step.steps,
    );
  }

  // Calculate Move (Active calories)
  // For now, we'll estimate based on steps (rough calculation)
  // 1 step ≈ 0.04 kcal for average person
  // TODO: Get real active calories from Health Connect if available
  final moveCurrent = todaySteps * 0.04;

  // Calculate Exercise minutes
  // TODO: Get real exercise minutes from Health Connect
  // For now, we'll use a mock value or calculate from steps
  // If user has > 5000 steps, consider some exercise time
  final exerciseCurrent = todaySteps > 5000 ? (todaySteps / 1000) * 2 : 0.0;

  // Calculate Stand hours
  // TODO: Get real stand hours from Health Connect
  // For now, estimate based on steps (if > 100 steps/hour, consider standing)
  final standHours = todaySteps > 0 ? (todaySteps / 100).clamp(0.0, 12.0) : 0.0;

  return ActivityData(
    moveCurrent: moveCurrent,
    moveGoal: 270.0,
    exerciseCurrent: exerciseCurrent,
    exerciseGoal: 25.0,
    standCurrent: standHours,
    standGoal: 12.0,
    steps: todaySteps,
  );
});
