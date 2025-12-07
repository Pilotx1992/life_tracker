import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking steps using device's built-in step counter sensor
class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  // Stream controllers
  final StreamController<int> _todayStepsController =
      StreamController<int>.broadcast();
  StreamSubscription<StepCount>? _stepCountSubscription;

  // State
  int _stepCountAtMidnight = 0;
  int _currentStepCount = 0;
  DateTime? _lastResetDate;

  static const String _stepCountAtMidnightKey = 'step_count_at_midnight';
  static const String _lastResetDateKey = 'last_reset_date';

  /// Stream of today's step count (updates in real-time)
  Stream<int> get todayStepsStream => _todayStepsController.stream;

  /// Current step count for today
  int get todaySteps =>
      (_currentStepCount - _stepCountAtMidnight).clamp(0, 999999);

  /// Initialize the pedometer service
  Future<void> initialize() async {
    await _loadSavedState();
    _checkDayReset();
    _startListening();
  }

  /// Load saved state from shared preferences
  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    _stepCountAtMidnight = prefs.getInt(_stepCountAtMidnightKey) ?? 0;
    final lastResetDateStr = prefs.getString(_lastResetDateKey);
    if (lastResetDateStr != null) {
      _lastResetDate = DateTime.tryParse(lastResetDateStr);
    }
  }

  /// Save state to shared preferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepCountAtMidnightKey, _stepCountAtMidnight);
    await prefs.setString(_lastResetDateKey, DateTime.now().toIso8601String());
  }

  /// Check if we need to reset for a new day
  void _checkDayReset() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null || _lastResetDate!.isBefore(todayStart)) {
      // New day - reset the offset
      _stepCountAtMidnight = _currentStepCount;
      _lastResetDate = todayStart;
      _saveState();
    }
  }

  /// Start listening to step count events
  void _startListening() {
    // Cancel existing subscription if any
    _stepCountSubscription?.cancel();

    // Listen to step count stream
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: false,
    );
  }

  /// Handle step count updates
  void _onStepCount(StepCount event) {
    _currentStepCount = event.steps;

    // Check for day reset
    _checkDayReset();

    // Emit today's steps
    final steps = todaySteps;
    _todayStepsController.add(steps);
  }

  /// Handle step count errors
  void _onStepCountError(Object error) {
    // Log error but don't crash - just emit last known value
    _todayStepsController.addError(error);
  }

  /// Manually set the step count (for syncing with Health Connect)
  void setStepCount(int steps) {
    if (steps > _currentStepCount) {
      _currentStepCount = steps;
      _todayStepsController.add(todaySteps);
    }
  }

  /// Dispose resources
  void dispose() {
    _stepCountSubscription?.cancel();
    _todayStepsController.close();
  }
}
