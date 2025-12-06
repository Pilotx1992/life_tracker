import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Activity Rings Widget - Huawei Health style
/// Displays 3 nested rings (Move, Exercise, Stand) with Steps in center
class ActivityRingsWidget extends StatelessWidget {
  final double moveProgress; // 0.0 to 1.0
  final double exerciseProgress; // 0.0 to 1.0
  final double standProgress; // 0.0 to 1.0
  final int steps;
  final double moveCurrent;
  final double moveGoal;
  final double exerciseCurrent;
  final double exerciseGoal;
  final double standCurrent;
  final double standGoal;
  final ThemeData theme;

  const ActivityRingsWidget({
    super.key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
    required this.steps,
    required this.moveCurrent,
    required this.moveGoal,
    required this.exerciseCurrent,
    required this.exerciseGoal,
    required this.standCurrent,
    required this.standGoal,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, animationValue, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF5F7FA),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Large Activity Rings
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring (Move - Red)
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: (moveProgress * animationValue).clamp(0.0, 1.0),
                        strokeWidth: 18,
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                    // Middle ring (Exercise - Orange)
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value:
                            (exerciseProgress * animationValue).clamp(0.0, 1.0),
                        strokeWidth: 18,
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF9500),
                        ),
                      ),
                    ),
                    // Inner ring (Stand - Blue)
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: (standProgress * animationValue).clamp(0.0, 1.0),
                        strokeWidth: 18,
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF007AFF),
                        ),
                      ),
                    ),
                    // Center content with gradient background
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            NumberFormat('#,###').format(steps),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Steps',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Activity Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActivityMetric(
                    context,
                    'Move',
                    moveCurrent.toStringAsFixed(0),
                    moveGoal.toStringAsFixed(0),
                    'kcal',
                    const Color(0xFFFF3B30),
                    moveProgress,
                  ),
                  _buildActivityMetric(
                    context,
                    'Exercise',
                    exerciseCurrent.toStringAsFixed(0),
                    exerciseGoal.toStringAsFixed(0),
                    'min',
                    const Color(0xFFFF9500),
                    exerciseProgress,
                  ),
                  _buildActivityMetric(
                    context,
                    'Stand',
                    standCurrent.toStringAsFixed(0),
                    standGoal.toStringAsFixed(0),
                    'h',
                    const Color(0xFF007AFF),
                    standProgress,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityMetric(
    BuildContext context,
    String label,
    String current,
    String goal,
    String unit,
    Color color,
    double progress,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 4,
                  backgroundColor: theme.brightness == Brightness.dark
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          current,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '/$goal $unit',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
