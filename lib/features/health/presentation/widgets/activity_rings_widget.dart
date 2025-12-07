import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Activity Arcs Widget - Modern arc-style design
/// Displays 3 nested arcs (Move, Exercise, Stand) from 8 o'clock to 4 o'clock
/// with Steps in center
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
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
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
              // Activity Arcs
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Custom painted arcs
                    CustomPaint(
                      size: const Size(240, 240),
                      painter: _ActivityArcsPainter(
                        moveProgress:
                            (moveProgress * animationValue).clamp(0.0, 1.0),
                        exerciseProgress:
                            (exerciseProgress * animationValue).clamp(0.0, 1.0),
                        standProgress:
                            (standProgress * animationValue).clamp(0.0, 1.0),
                        isDark: theme.brightness == Brightness.dark,
                      ),
                    ),
                    // Arc start icons positioned at 7 o'clock
                    // Move icon (fire) - outer arc
                    _buildArcIcon(
                      icon: Icons.local_fire_department,
                      color: const Color(0xFFFF3B30),
                      radius: 120 - 8.5, // moveRadius
                    ),
                    // Exercise icon (running) - middle arc
                    _buildArcIcon(
                      icon: Icons.directions_run,
                      color: const Color(0xFFFF9500),
                      radius: 120 - 8.5 - 21, // exerciseRadius
                    ),
                    // Stand icon (person) - inner arc
                    _buildArcIcon(
                      icon: Icons.accessibility_new,
                      color: const Color(0xFF007AFF),
                      radius: 120 - 8.5 - 42, // standRadius
                    ),
                    // Center content with gradient background
                    Container(
                      width: 110,
                      height: 110,
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
                              fontSize: 28,
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
              const SizedBox(height: 1),
              // Activity Metrics Row (no circles)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActivityMetric(
                    'Move',
                    moveCurrent.toStringAsFixed(0),
                    moveGoal.toStringAsFixed(0),
                    'kcal',
                    const Color(0xFFFF3B30),
                  ),
                  _buildActivityMetric(
                    'Exercise',
                    exerciseCurrent.toStringAsFixed(0),
                    exerciseGoal.toStringAsFixed(0),
                    'min',
                    const Color(0xFFFF9500),
                  ),
                  _buildActivityMetric(
                    'Stand',
                    standCurrent.toStringAsFixed(0),
                    standGoal.toStringAsFixed(0),
                    'h',
                    const Color(0xFF007AFF),
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
    String label,
    String current,
    String goal,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        // Label with color indicator dot on the left
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
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

  /// Builds an icon positioned at the start of an arc (7 o'clock position)
  Widget _buildArcIcon({
    required IconData icon,
    required Color color,
    required double radius,
  }) {
    // 7 o'clock position = 120° in Flutter's coordinate system
    const double angle = 120 * math.pi / 180;
    final double x = radius * math.cos(angle);
    final double y = radius * math.sin(angle);

    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}

/// Custom painter for activity arcs
/// Draws 3 nested arcs from 7 o'clock to 5 o'clock position
class _ActivityArcsPainter extends CustomPainter {
  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;
  final bool isDark;

  // Arc configuration
  static const double strokeWidth = 17.0;
  static const double arcGap =
      21.0; // Gap between arcs (21 - 14 = 7px edge gap)

  // Colors
  static const Color moveColor = Color(0xFFFF3B30);
  static const Color exerciseColor = Color(0xFFFF9500);
  static const Color standColor = Color(0xFF007AFF);

  // Arc angles (in radians)
  // Start at 7 o'clock (120° in Flutter where 0° is 3 o'clock)
  // Sweep 300° clockwise to reach 5 o'clock
  static const double startAngle = 120 * math.pi / 180; // 7 o'clock position
  static const double sweepAngle =
      300 * math.pi / 180; // 300° sweep to 5 o'clock

  _ActivityArcsPainter({
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate radii for each arc
    final moveRadius = size.width / 2 - strokeWidth / 2;
    final exerciseRadius = moveRadius - arcGap;
    final standRadius = exerciseRadius - arcGap;

    // Draw Move arc (outer - red)
    _drawArc(
      canvas,
      center,
      moveRadius,
      moveColor,
      moveProgress,
    );

    // Draw Exercise arc (middle - orange)
    _drawArc(
      canvas,
      center,
      exerciseRadius,
      exerciseColor,
      exerciseProgress,
    );

    // Draw Stand arc (inner - blue)
    _drawArc(
      canvas,
      center,
      standRadius,
      standColor,
      standProgress,
    );
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double progress,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc (light color)
    final backgroundPaint = Paint()
      ..color =
          isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Progress arc (solid color)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Clamp progress to max 1.0 for visual
      final clampedProgress = progress.clamp(0.0, 1.0);
      final progressSweep = sweepAngle * clampedProgress;

      canvas.drawArc(
        rect,
        startAngle,
        progressSweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ActivityArcsPainter oldDelegate) {
    return moveProgress != oldDelegate.moveProgress ||
        exerciseProgress != oldDelegate.exerciseProgress ||
        standProgress != oldDelegate.standProgress ||
        isDark != oldDelegate.isDark;
  }
}
