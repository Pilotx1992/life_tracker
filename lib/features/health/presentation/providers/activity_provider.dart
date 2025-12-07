import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/health_provider.dart';
import 'package:life_tracker/core/providers/pedometer_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_providers.dart';

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
/// Combines data from Pedometer (real-time) and Health Connect
final activityDataProvider = Provider<ActivityData>((ref) {
  final healthState = ref.watch(healthConnectProvider);
  final pedometerSteps = ref.watch(currentPedometerStepsProvider);
  final latestWeightAsync = ref.watch(latestWeightProvider);

  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  // Calculate today's steps from Health Connect
  int healthConnectSteps = 0;
  if (healthState.stepsData.isNotEmpty) {
    final todayStepsData = healthState.stepsData.where((step) {
      return step.date.isAfter(todayStart) && step.date.isBefore(todayEnd);
    }).toList();
    healthConnectSteps = todayStepsData.fold<int>(
      0,
      (sum, step) => sum + step.steps,
    );
  }

  // Use the higher value between pedometer and Health Connect
  final todaySteps =
      pedometerSteps > healthConnectSteps ? pedometerSteps : healthConnectSteps;

  // === IMPROVED CALORIE CALCULATION ===
  // Base formula: calories = steps × MET × weight(kg) / 1000
  // Walking MET ≈ 3.5, average step = 0.0005 km
  // Simplified: calories ≈ steps × 0.04 × (weight/70)
  double userWeight = 70.0; // Default weight if not available
  final weightEntry = latestWeightAsync;
  if (weightEntry != null) {
    userWeight = weightEntry.weight;
  }

  // Calorie calculation adjusted for user's weight
  // Formula: steps × 0.04 × (weight / 70)
  // This gives higher calories for heavier people
  final calorieMultiplier = userWeight / 70.0;
  final moveCurrent = todaySteps * 0.04 * calorieMultiplier;

  // === EXERCISE MINUTES ===
  // Exercise counts only for intentional physical activity
  // Threshold: at least 3000 steps to start counting exercise
  // (casual walking throughout the day doesn't count as exercise)
  double exerciseCurrent = 0.0;
  if (todaySteps >= 3000) {
    // Every 150 steps above 3000 = 1 minute of exercise
    // This is more conservative and realistic
    exerciseCurrent = ((todaySteps - 3000) / 150).clamp(0.0, 120.0);
  }

  // === STAND HOURS ===
  // Simple calculation: 1 stand hour per 500 steps
  // Maximum: number of hours elapsed since midnight
  final hoursElapsedToday = today.hour + (today.minute / 60);
  double standHours = 0.0;

  if (todaySteps > 0) {
    // 1 stand hour per 500 steps, capped at hours elapsed
    standHours = (todaySteps / 500).clamp(0.0, hoursElapsedToday);
  }

  return ActivityData(
    moveCurrent: moveCurrent,
    moveGoal: 270.0,
    exerciseCurrent: exerciseCurrent,
    exerciseGoal: 30.0, // WHO recommendation
    standCurrent: standHours,
    standGoal: 12.0,
    steps: todaySteps,
  );
});
