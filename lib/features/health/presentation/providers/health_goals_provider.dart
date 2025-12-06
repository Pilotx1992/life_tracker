import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/domain/entities/health_goal.dart';

/// Provider for Health Goals
/// TODO: Implement full repository pattern when data layer is ready
final healthGoalsProvider = Provider<List<HealthGoal>>((ref) {
  // Mock default goals - will be replaced with real data source
  return [
    const HealthGoal(
      type: 'steps',
      target: 10000,
      current: 0,
      period: 'daily',
    ),
    const HealthGoal(
      type: 'calories',
      target: 2000,
      current: 0,
      period: 'daily',
    ),
    const HealthGoal(
      type: 'distance',
      target: 5.0,
      current: 0,
      period: 'daily',
    ),
    const HealthGoal(
      type: 'sleep',
      target: 8.0,
      current: 0,
      period: 'daily',
    ),
  ];
});

/// Provider for active goals only
final activeGoalsProvider = Provider<List<HealthGoal>>((ref) {
  final goals = ref.watch(healthGoalsProvider);
  return goals.where((goal) => goal.isActive).toList();
});

/// Provider for goal by type
final goalByTypeProvider = Provider.family<HealthGoal?, String>((ref, type) {
  final goals = ref.watch(healthGoalsProvider);
  try {
    return goals.firstWhere((goal) => goal.type == type && goal.isActive);
  } catch (e) {
    return null;
  }
});
