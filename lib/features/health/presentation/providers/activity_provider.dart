import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/health_provider.dart';
import 'package:life_tracker/core/providers/pedometer_provider.dart';
import 'package:life_tracker/core/utils/calorie_calculator.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_providers.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';

/// Data source enum for activity tracking
enum DataSource {
  pedometer,
  healthConnect,
  combined,
}

/// Activity data model
class ActivityData {
  final double moveCurrent; // Active calories burned
  final double moveGoal;
  final double exerciseCurrent; // Exercise minutes
  final double exerciseGoal;
  final double standCurrent; // Stand hours
  final double standGoal;
  final int steps;
  final int stepGoal; // Steps goal (default 10,000)
  final double distance; // Distance in km
  final double cadence; // Steps per minute
  final DataSource source;

  ActivityData({
    required this.moveCurrent,
    this.moveGoal = 270.0,
    required this.exerciseCurrent,
    this.exerciseGoal = 30.0,
    required this.standCurrent,
    this.standGoal = 12.0,
    required this.steps,
    this.stepGoal = 10000, // 10,000 steps = 100%
    this.distance = 0.0,
    this.cadence = 0.0,
    this.source = DataSource.combined,
  });

  double get moveProgress => (moveCurrent / moveGoal).clamp(0.0, 1.0);
  double get exerciseProgress =>
      (exerciseCurrent / exerciseGoal).clamp(0.0, 1.0);
  double get standProgress => (standCurrent / standGoal).clamp(0.0, 1.0);
  double get stepProgress => (steps / stepGoal).clamp(0.0, 1.0);

  /// Get activity level description
  String get activityLevel => CalorieCalculator.getActivityLevel(cadence);
}

/// Provider for Activity Rings data
/// Combines data from Pedometer (real-time) and Health Connect
/// Uses MET-based calculations for accurate calorie estimation
final activityDataProvider = Provider<ActivityData>((ref) {
  final healthState = ref.watch(healthConnectProvider);
  final pedometerSteps = ref.watch(currentPedometerStepsProvider);
  final latestWeight = ref.watch(latestWeightProvider);
  final profileAsync = ref.watch(userProfileProvider);

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
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
  final todaySteps = max(pedometerSteps, healthConnectSteps);

  // Determine data source
  final source = pedometerSteps > healthConnectSteps
      ? DataSource.pedometer
      : healthConnectSteps > 0
          ? DataSource.healthConnect
          : DataSource.pedometer;

  // Get user weight (default 70kg)
  final userWeight = latestWeight?.weight ?? 70.0;

  // Get user height for distance calculation (default 170cm)
  double heightCm = 170.0;
  profileAsync.whenData((profile) {
    if (profile?.heightInCm != null) {
      heightCm = profile!.heightInCm!;
    }
  });

  // Calculate active duration since 6 AM (typical wake time)
  const dayStartHour = 6;
  final activeStart = DateTime(now.year, now.month, now.day, dayStartHour);
  final activeDuration =
      now.isAfter(activeStart) ? now.difference(activeStart) : Duration.zero;

  // Calculate cadence (steps per minute) for MET determination
  final cadence = activeDuration.inMinutes > 0
      ? todaySteps / activeDuration.inMinutes
      : 0.0;

  // === MET-BASED CALORIE CALCULATION ===
  final calories = CalorieCalculator.calculateCalories(
    steps: todaySteps,
    duration: activeDuration,
    weightKg: userWeight,
  );

  // === DISTANCE CALCULATION ===
  final distance = CalorieCalculator.calculateDistance(
    steps: todaySteps,
    heightCm: heightCm,
    cadence: cadence,
  );

  // === EXERCISE MINUTES ===
  final exerciseMinutes =
      CalorieCalculator.calculateExerciseMinutes(todaySteps);

  // === STAND HOURS ===
  final hoursElapsed = now.hour + (now.minute / 60);
  final standHours =
      CalorieCalculator.calculateStandHours(todaySteps, hoursElapsed);

  return ActivityData(
    moveCurrent: calories,
    moveGoal: 270.0,
    exerciseCurrent: exerciseMinutes,
    exerciseGoal: 30.0,
    standCurrent: standHours,
    standGoal: 12.0,
    steps: todaySteps,
    distance: distance,
    cadence: cadence,
    source: source,
  );
});
