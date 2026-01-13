import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/utils/calorie_calculator.dart';
import 'package:life_tracker/features/health/data/repositories/smart_activity_repository.dart';
import 'package:life_tracker/features/health/domain/entities/activity_summary.dart';

/// Data source enum for activity tracking (mapped from Domain)
enum DataSource {
  pedometer,
  healthConnect,
  combined,
}

/// Activity data model (Presentation)
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
  final double cadence; // Steps per minute (Calculated or Estimated)
  final DataSource source;

  ActivityData({
    required this.moveCurrent,
    this.moveGoal = 270.0,
    required this.exerciseCurrent,
    this.exerciseGoal = 30.0,
    required this.standCurrent,
    this.standGoal = 12.0,
    required this.steps,
    this.stepGoal = 10000,
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

/// Stream provider for activity summary from repository
final activitySummaryStreamProvider = StreamProvider<ActivitySummary>((ref) {
  final repository = ref.watch(smartActivityRepositoryProvider);
  return repository.getActivityStream();
});

/// Provider for Activity Rings data
/// Consumes the SmartRepository Logic
final activityDataProvider = Provider<ActivityData>((ref) {
  final summaryAsync = ref.watch(activitySummaryStreamProvider);

  // Default values
  double move = 0;
  double exercise = 0;
  double stand = 0;
  int steps = 0;
  double distance = 0;
  DataSource source = DataSource.pedometer;

  // Use data if available
  summaryAsync.whenData((summary) {
    move = summary.activeCalories;
    exercise = summary.exerciseMinutes;
    stand = summary.standHours;
    steps = summary.steps;
    distance = summary.distanceMeters / 1000.0; // Convert to km
    source = summary.source == ActivityDataSource.healthConnect
        ? DataSource.healthConnect
        : DataSource.pedometer;
  });

  // [Phase 2] Goals will be fetched from UserProfile or Settings

  return ActivityData(
    moveCurrent: move,
    moveGoal: 270.0,
    exerciseCurrent: exercise,
    exerciseGoal: 30.0,
    standCurrent: stand,
    standGoal: 12.0,
    steps: steps,
    stepGoal: 10000,
    distance: distance,
    source: source,
  );
});
