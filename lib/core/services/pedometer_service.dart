import 'dart:async';
import 'package:flutter/foundation.dart';
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
  Timer? _dayCheckTimer;
  Timer? _midnightTimer;

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
    _startDayCheckTimer();
  }

  /// Track if we need to initialize the offset on first event
  bool _isFirstLoad = false;

  /// Load saved state from shared preferences
  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we have a saved state
    if (prefs.containsKey(_stepCountAtMidnightKey)) {
      _stepCountAtMidnight = prefs.getInt(_stepCountAtMidnightKey) ?? 0;
      _isFirstLoad = false;
    } else {
      // First time initialization - mark as first load
      // We will set the midnight offset to the CURRENT steps when we receive the first event
      _isFirstLoad = true;
      _stepCountAtMidnight = 0;
    }

    final lastResetDateStr = prefs.getString(_lastResetDateKey);
    if (lastResetDateStr != null) {
      _lastResetDate = DateTime.tryParse(lastResetDateStr);
    } else {
      // First time initialization - set to today
      _lastResetDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
    }

    if (kDebugMode) {
      debugPrint('📱 Pedometer: Loaded saved state');
      debugPrint('   Steps at midnight: $_stepCountAtMidnight');
      debugPrint('   isFirstLoad: $_isFirstLoad');
      debugPrint('   Last reset date: $_lastResetDate');
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
      if (kDebugMode) {
        debugPrint('🔄 Pedometer: Day changed - performing reset');
        debugPrint('   Last reset: $_lastResetDate');
        debugPrint('   Today start: $todayStart');
        debugPrint('   Current steps: $_currentStepCount');
      }

      _stepCountAtMidnight = _currentStepCount;
      _lastResetDate = todayStart;
      _saveState();

      // Emit 0 steps for the new day
      _todayStepsController.add(0);

      if (kDebugMode) {
        debugPrint(
            '✅ Pedometer: Reset complete - steps at midnight: $_stepCountAtMidnight');
      }
    } else {
      if (kDebugMode) {
        debugPrint('✓ Pedometer: Same day, no reset needed');
        debugPrint('   Last reset: $_lastResetDate');
        debugPrint('   Today start: $todayStart');
      }
    }
  }

  /// Start listening to step count events
  void _startListening() {
    // Cancel existing subscription if any
    _stepCountSubscription?.cancel();

    try {
      // Listen to step count stream
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );
    } catch (e) {
      // Step counting not available on this device (e.g., emulators)
      // Emit 0 steps so the app continues to work
      _todayStepsController.add(0);
    }
  }

  /// Start a periodic timer to check for day transitions
  /// Also schedules an exact midnight reset
  void _startDayCheckTimer() {
    // Cancel existing timers
    _dayCheckTimer?.cancel();
    _midnightTimer?.cancel();

    // Calculate time until next midnight
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);

    if (kDebugMode) {
      debugPrint(
          '⏰ Pedometer: Scheduled midnight reset in ${timeUntilMidnight.inHours}h ${timeUntilMidnight.inMinutes % 60}m');
      debugPrint('   Next midnight: $nextMidnight');
    }

    // Schedule exact midnight reset
    _midnightTimer = Timer(timeUntilMidnight, () {
      if (kDebugMode) {
        debugPrint('🌙 Pedometer: Midnight timer fired!');
      }
      _performMidnightReset();
      // After midnight reset, schedule the next midnight
      _startDayCheckTimer();
    });

    // Run periodic check every 15 minutes as backup
    // (in case app was suspended during midnight or timer didn't fire)
    _dayCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _checkDayReset(),
    );
  }

  /// Perform midnight reset explicitly
  void _performMidnightReset() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (kDebugMode) {
      debugPrint('🔄 Pedometer: Performing midnight reset');
      debugPrint('   Time: $now');
      debugPrint('   Current total steps: $_currentStepCount');
    }

    // Reset the offset to current step count
    _stepCountAtMidnight = _currentStepCount;
    _lastResetDate = todayStart;
    _saveState();

    // Emit 0 steps for the new day
    _todayStepsController.add(0);

    if (kDebugMode) {
      debugPrint('✅ Pedometer: Midnight reset complete');
      debugPrint('   Steps at midnight: $_stepCountAtMidnight');
      debugPrint('   Today steps: 0');
    }
  }

  /// Handle step count updates
  void _onStepCount(StepCount event) {
    _currentStepCount = event.steps;

    // FIX: If this is the FIRST time running the app (no saved state),
    // set the midnight offset to the current step count so today starts at 0.
    if (_isFirstLoad) {
      if (kDebugMode) {
        debugPrint(
            '🆕 Pedometer: First load detected. Setting baseline to $_currentStepCount');
      }
      _stepCountAtMidnight = _currentStepCount;
      _isFirstLoad = false;
      _saveState();
    }

    // FIX: Detect device reboot
    // If current steps < stored midnight steps, the device must have rebooted
    // (since the sensor resets to 0 on reboot).
    // In this case, we reset the offset to 0 to start counting from scratch.
    if (_currentStepCount < _stepCountAtMidnight) {
      if (kDebugMode) {
        debugPrint(
            '⚠️ Pedometer: Device reboot detected (Current: $_currentStepCount < Saved: $_stepCountAtMidnight)');
        debugPrint('   Resetting baseline to 0');
      }
      _stepCountAtMidnight = 0;
      _saveState();
    }

    if (kDebugMode) {
      debugPrint('📊 Pedometer: Step count update received');
      debugPrint('   Current total steps: $_currentStepCount');
      debugPrint('   Steps at midnight: $_stepCountAtMidnight');
    }

    // Check for day reset
    _checkDayReset();

    // Emit today's steps
    final steps = todaySteps;
    _todayStepsController.add(steps);

    if (kDebugMode) {
      debugPrint('   Today\'s steps: $steps');
    }
  }

  /// Handle step count errors
  void _onStepCountError(Object error) {
    // Step counting not available - fall back to 0 steps gracefully
    // This happens on emulators and devices without step counting hardware
    _todayStepsController.add(0);
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
    _dayCheckTimer?.cancel();
    _midnightTimer?.cancel();
    _todayStepsController.close();
  }
}
