import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/health/presentation/providers/activity_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/sleep_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/workout_provider.dart';

/// Health Insights Widget
/// Displays weekly summaries, achievements, and health tips
class HealthInsightsWidget extends ConsumerWidget {
  final ThemeData theme;

  const HealthInsightsWidget({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityData = ref.watch(activityDataProvider);
    final averageSleep = ref.watch(averageSleepHoursProvider);
    final todayWorkouts = ref.watch(todayWorkoutsProvider);
    final weightListAsync = ref.watch(weightListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Health Insights',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Weekly Summary Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.brightness == Brightness.dark
                    ? [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withValues(alpha: 0.8),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF8F9FA),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Avg Steps',
                        NumberFormat('#,###').format(activityData.steps),
                        Icons.directions_walk,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Workouts',
                        '${todayWorkouts.length}',
                        Icons.fitness_center,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildInsightItem(
                        context,
                        'Avg Sleep',
                        averageSleep != null
                            ? '${averageSleep.toStringAsFixed(1)}h'
                            : '--',
                        Icons.bedtime,
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                weightListAsync.when(
                  data: (weights) {
                    if (weights.length < 2) {
                      return const SizedBox.shrink();
                    }
                    weights.sort((a, b) => b.date.compareTo(a.date));
                    final latest = weights.first;
                    final previous = weights[1];
                    final change = latest.weight - previous.weight;

                    return Row(
                      children: [
                        Icon(
                          change < 0 ? Icons.trending_down : Icons.trending_up,
                          color: change < 0 ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Weight ${change < 0 ? 'down' : 'up'} ${change.abs().toStringAsFixed(1)} kg this week',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Health Tips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getHealthTip(activityData.steps, averageSleep),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _getHealthTip(int steps, double? avgSleep) {
    if (steps < 5000) {
      return 'Try to reach 10,000 steps today for better health!';
    } else if (avgSleep != null && avgSleep < 7) {
      return 'Aim for 7-9 hours of sleep for optimal health.';
    } else {
      return 'Great job! Keep up the healthy habits.';
    }
  }
}
