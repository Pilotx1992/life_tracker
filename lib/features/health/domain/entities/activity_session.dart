import 'package:equatable/equatable.dart';

/// Represents an activity session for tracking cadence and MET values
///
/// An activity session tracks steps from a specific start time,
/// allowing for accurate cadence calculations which are used
/// for MET-based calorie estimation.
class ActivitySession extends Equatable {
  final DateTime startTime;
  final int stepsAtStart;
  final int currentSteps;

  const ActivitySession({
    required this.startTime,
    required this.stepsAtStart,
    required this.currentSteps,
  });

  /// Duration since session started
  Duration get duration => DateTime.now().difference(startTime);

  /// Steps taken during this session
  int get sessionSteps => (currentSteps - stepsAtStart).clamp(0, 999999);

  /// Cadence (steps per minute)
  double get cadence {
    final minutes = duration.inMinutes;
    if (minutes == 0) return 0;
    return sessionSteps / minutes;
  }

  /// Create an updated session with new current steps
  ActivitySession withUpdatedSteps(int newCurrentSteps) {
    return ActivitySession(
      startTime: startTime,
      stepsAtStart: stepsAtStart,
      currentSteps: newCurrentSteps,
    );
  }

  /// Create a new session starting from now
  factory ActivitySession.startNew(int currentSteps) {
    return ActivitySession(
      startTime: DateTime.now(),
      stepsAtStart: currentSteps,
      currentSteps: currentSteps,
    );
  }

  /// Create a session starting from today's midnight
  factory ActivitySession.fromMidnight(int currentSteps) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    return ActivitySession(
      startTime: midnight,
      stepsAtStart: 0,
      currentSteps: currentSteps,
    );
  }

  ActivitySession copyWith({
    DateTime? startTime,
    int? stepsAtStart,
    int? currentSteps,
  }) {
    return ActivitySession(
      startTime: startTime ?? this.startTime,
      stepsAtStart: stepsAtStart ?? this.stepsAtStart,
      currentSteps: currentSteps ?? this.currentSteps,
    );
  }

  @override
  List<Object?> get props => [startTime, stepsAtStart, currentSteps];
}
