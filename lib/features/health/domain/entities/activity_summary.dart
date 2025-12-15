import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_summary.freezed.dart';

enum ActivityDataSource {
  phoneSensor, // Pedometer/Physics Engine
  healthConnect, // Watch/External App
  manual,
  combined
}

@freezed
class ActivitySummary with _$ActivitySummary {
  const factory ActivitySummary({
    required int steps,
    required double activeCalories, // kcal
    required double distanceMeters,
    required double exerciseMinutes,
    required double standHours,
    required DateTime date,
    required ActivityDataSource source,
    @Default(0.85)
    double confidence, // 0.0-1.0, default to phone sensor confidence
  }) = _ActivitySummary;

  factory ActivitySummary.empty() => ActivitySummary(
        steps: 0,
        activeCalories: 0,
        distanceMeters: 0,
        exerciseMinutes: 0,
        standHours: 0,
        date: DateTime.now(),
        source: ActivityDataSource.phoneSensor,
        confidence: 0.85,
      );
}
