import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';

/// Weight Trend Chart Widget
/// Displays a line chart with area fill and interactive points
class WeightTrendChart extends StatelessWidget {
  final List<WeightEntry> weights;
  final Color color;
  final ThemeData theme;
  final VoidCallback? onViewAll;

  const WeightTrendChart({
    super.key,
    required this.weights,
    required this.color,
    required this.theme,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (weights.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(40),
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
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.show_chart,
                size: 56,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No weight data yet',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first weight entry to see trends',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show last 7-30 entries
    final recentWeights = weights.take(30).toList();
    final maxWeight =
        recentWeights.map((w) => w.weight).reduce((a, b) => a > b ? a : b);
    final minWeight =
        recentWeights.map((w) => w.weight).reduce((a, b) => a < b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight Trend',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Line chart
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _WeightChartPainter(
                weights: recentWeights,
                maxWeight: maxWeight,
                minWeight: minWeight,
                color: color,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 16),
          // Weight entries list
          ...recentWeights.take(3).map((weight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd').format(weight.date),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${weight.weight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Custom painter for weight trend chart
class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> weights;
  final double maxWeight;
  final double minWeight;
  final Color color;

  _WeightChartPainter({
    required this.weights,
    required this.maxWeight,
    required this.minWeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final range = maxWeight - minWeight;
    if (range <= 0) return;

    final stepX = size.width / (weights.length - 1);
    final path = Path();

    // Build path
    for (int i = 0; i < weights.length; i++) {
      final weight = weights[i].weight;
      final normalizedWeight = (weight - minWeight) / range;
      final x = i * stepX;
      final y = size.height - (normalizedWeight * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill area under curve
    final fillPath = Path();
    for (int i = 0; i < weights.length; i++) {
      final weight = weights[i].weight;
      final normalizedWeight = (weight - minWeight) / range;
      final x = i * stepX;
      final y = size.height - (normalizedWeight * size.height);
      if (i == 0) {
        fillPath.moveTo(x, y);
      } else {
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < weights.length; i++) {
      final weight = weights[i].weight;
      final normalizedWeight = (weight - minWeight) / range;
      final x = i * stepX;
      final y = size.height - (normalizedWeight * size.height);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
