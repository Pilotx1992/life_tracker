import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking stand hours based on hourly step activity
///
/// A "stand hour" is counted when the user has taken at least
/// [minStepsPerHour] steps during that hour interval.
class StandHoursService {
  static final StandHoursService _instance = StandHoursService._internal();
  factory StandHoursService() => _instance;
  StandHoursService._internal();

  /// Minimum steps required per hour to count as a stand hour
  static const int minStepsPerHour = 50;

  /// Key prefix for storing hourly step data
  static const String _hourlyStepsPrefix = 'hourly_steps_';
  static const String _lastRecordedDateKey = 'stand_hours_last_date';

  /// Map of hour -> steps for today
  final Map<int, int> _hourlySteps = {};

  /// Last known step count for delta calculation
  int _lastStepCount = 0;

  /// Initialize the service and load saved state
  Future<void> initialize() async {
    await _loadSavedState();
    _checkDayReset();
  }

  /// Load saved state from SharedPreferences
  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's a new day
    final lastDateStr = prefs.getString(_lastRecordedDateKey);
    if (lastDateStr != null) {
      final lastDate = DateTime.tryParse(lastDateStr);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      if (lastDate != null && lastDate.isBefore(todayStart)) {
        // New day - clear old data
        await _clearSavedState(prefs);
        return;
      }
    }

    // Load hourly steps for today
    for (int hour = 0; hour < 24; hour++) {
      final steps = prefs.getInt('$_hourlyStepsPrefix$hour');
      if (steps != null) {
        _hourlySteps[hour] = steps;
      }
    }
  }

  /// Clear saved state
  Future<void> _clearSavedState(SharedPreferences prefs) async {
    for (int hour = 0; hour < 24; hour++) {
      await prefs.remove('$_hourlyStepsPrefix$hour');
    }
    _hourlySteps.clear();
  }

  /// Check if we need to reset for a new day
  void _checkDayReset() {
    // This is handled in _loadSavedState
  }

  /// Record steps for the current hour
  ///
  /// Call this whenever the step count updates
  Future<void> recordSteps(int totalSteps) async {
    final currentHour = DateTime.now().hour;

    // Calculate steps for this hour
    if (_lastStepCount == 0) {
      _lastStepCount = totalSteps;
    }

    final hourSteps = _hourlySteps[currentHour] ?? 0;
    final stepsDelta = totalSteps - _lastStepCount;

    if (stepsDelta > 0) {
      _hourlySteps[currentHour] = hourSteps + stepsDelta;
      _lastStepCount = totalSteps;

      // Persist
      await _saveState();
    }
  }

  /// Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in _hourlySteps.entries) {
      await prefs.setInt('$_hourlyStepsPrefix${entry.key}', entry.value);
    }

    await prefs.setString(
        _lastRecordedDateKey, DateTime.now().toIso8601String(),);
  }

  /// Calculate total stand hours (hours with >= [minStepsPerHour] steps)
  int calculateStandHours() {
    return _hourlySteps.values
        .where((steps) => steps >= minStepsPerHour)
        .length;
  }

  /// Get hourly step breakdown for today
  Map<int, int> getHourlyBreakdown() {
    return Map.unmodifiable(_hourlySteps);
  }

  /// Reset for a new day (call at midnight)
  Future<void> resetDaily() async {
    _hourlySteps.clear();
    _lastStepCount = 0;

    final prefs = await SharedPreferences.getInstance();
    await _clearSavedState(prefs);
  }

  /// Dispose resources
  void dispose() {
    _hourlySteps.clear();
  }
}
