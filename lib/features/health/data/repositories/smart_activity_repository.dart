import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/health_provider.dart';
import 'package:life_tracker/core/providers/pedometer_provider.dart';
import 'package:life_tracker/core/utils/calorie_calculator.dart';
import 'package:life_tracker/features/health/domain/entities/activity_summary.dart';
import 'package:life_tracker/features/health/domain/repositories/activity_repository.dart';

class SmartActivityRepository implements ActivityRepository {
  final Ref _ref;
  final StreamController<ActivitySummary> _controller =
      StreamController<ActivitySummary>.broadcast();
  StreamSubscription<int>? _pedometerSub;
  ProviderSubscription? _healthSub;

  SmartActivityRepository(this._ref) {
    _init();
  }

  void _init() {
    // Listen to Health Connect changes
    _healthSub = _ref.listen<HealthConnectState>(
      healthConnectProvider,
      (previous, next) {
        _emitActivityUpdate();
      },
      fireImmediately: true,
    );

    // Listen to Pedometer changes
    _pedometerSub =
        _ref.read(pedometerServiceProvider).todayStepsStream.listen((steps) {
      _emitActivityUpdate(pedometerSteps: steps);
    });
  }

  void _emitActivityUpdate({int? pedometerSteps}) {
    final healthState = _ref.read(healthConnectProvider);
    final int currentPedometerSteps =
        (pedometerSteps ?? _ref.read(currentPedometerStepsProvider)) as int;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // 1. Get Health Connect Data for Today
    int healthSteps = 0;
    double healthCalories = 0.0;
    double healthDistance = 0.0;

    if (healthState.stepsData.isNotEmpty) {
      healthSteps = healthState.stepsData
          .where((d) => d.date.isAfter(todayStart) && d.date.isBefore(todayEnd))
          .fold(0, (sum, item) => sum + item.steps);
    }

    if (healthState.activeEnergyData.isNotEmpty) {
      healthCalories = healthState.activeEnergyData
          .where((d) => d.date.isAfter(todayStart) && d.date.isBefore(todayEnd))
          .fold(0.0, (sum, item) => sum + item.calories);
    }

    if (healthState.distanceData.isNotEmpty) {
      healthDistance = healthState.distanceData
          .where((d) => d.date.isAfter(todayStart) && d.date.isBefore(todayEnd))
          .fold(0.0, (sum, item) => sum + item.distance);
    }

    // 2. Tiered Confidence Logic
    // PRD Section 13.4: Data Aging Refinement
    // Tier 1: Health Connect (< 5 mins) → 95% confidence
    // Tier 2: Health Connect (5-30 mins) → 80% confidence
    // Tier 3: Health Connect (> 30 mins) OR no data → Fallback to phone sensor (85%)

    final lastSync = healthState.lastSyncTime;
    Duration? dataAge;
    if (lastSync != null) {
      dataAge = now.difference(lastSync);
    }

    // Determine source and confidence based on data age
    ActivityDataSource source;
    double confidence;
    bool useHealthConnect = false;

    if (dataAge != null && healthSteps > 0) {
      if (dataAge < const Duration(minutes: 5)) {
        // Tier 1: Fresh wearable data
        source = ActivityDataSource.healthConnect;
        confidence = 0.95;
        useHealthConnect = true;
      } else if (dataAge < const Duration(minutes: 30)) {
        // Tier 2: Slightly stale but acceptable
        source = ActivityDataSource.healthConnect;
        confidence = 0.80;
        useHealthConnect = true;
      } else {
        // Tier 3: Too old - fallback to phone
        source = ActivityDataSource.phoneSensor;
        confidence = 0.85;
        useHealthConnect = false;
      }
    } else {
      // No Health Connect data at all
      source = ActivityDataSource.phoneSensor;
      confidence = 0.85;
      useHealthConnect = false;
    }

    if (useHealthConnect) {
      // PRIORITY 1/2: Health Connect (with tiered confidence)
      // PRD Module B: Use HealthDataType.ACTIVE_ENERGY_BURNED directly

      final exerciseMinutes =
          CalorieCalculator.calculateExerciseMinutes(healthSteps);
      final standHours = CalorieCalculator.calculateStandHours(
          healthSteps, now.hour + now.minute / 60.0);

      _controller.add(ActivitySummary(
        steps: healthSteps,
        activeCalories: healthCalories,
        distanceMeters: healthDistance,
        exerciseMinutes: exerciseMinutes,
        standHours: standHours,
        date: now,
        source: source,
        confidence: confidence,
      ));
    } else {
      // PRIORITY 3: Physics Engine directly (Pedometer Service)
      // PRD Module A: Calculate Steps and Calories without Heart Rate data.

      final usedSteps = currentPedometerSteps;

      // Get weight for calculation
      final weight = healthState.weightData.isNotEmpty
          ? healthState.weightData.first.weight
          : 70.0; // Default

      final calculatedCalories = CalorieCalculator.calculateCaloriesSimple(
          steps: usedSteps, weightKg: weight);

      final calculatedDistance = CalorieCalculator.calculateDistance(
        steps: usedSteps,
        heightCm: 170.0, // Default
      );

      final exerciseMinutes =
          CalorieCalculator.calculateExerciseMinutes(usedSteps);
      final standHours = CalorieCalculator.calculateStandHours(
          usedSteps, now.hour + now.minute / 60.0);

      _controller.add(ActivitySummary(
        steps: usedSteps,
        activeCalories: calculatedCalories,
        distanceMeters: calculatedDistance * 1000, // KM to Meters
        exerciseMinutes: exerciseMinutes,
        standHours: standHours,
        date: now,
        source: source,
        confidence: confidence,
      ));
    }
  }

  @override
  Stream<ActivitySummary> getActivityStream() {
    return _controller.stream;
  }

  @override
  Future<void> refresh() async {
    await _ref.read(healthConnectProvider.notifier).syncAllData(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now());
  }

  void dispose() {
    _pedometerSub?.cancel();
    _healthSub?.close();
    _controller.close();
  }
}

/// Provider for the repository
final smartActivityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final repo = SmartActivityRepository(ref);
  ref.onDispose(() => repo.dispose());
  return repo;
});
