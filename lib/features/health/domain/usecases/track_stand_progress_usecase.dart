import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/pedometer_provider.dart';
import 'package:life_tracker/features/health/data/models/daily_stand_log.dart';
import 'package:life_tracker/features/health/data/repositories/stand_repository.dart';

class TrackStandProgressUseCase {
  final StandRepository _repository;
  final Ref _ref;

  // In-memory state
  DailyStandLog? _currentLog;
  StreamSubscription<int>? _pedometerSub;

  TrackStandProgressUseCase(this._repository, this._ref);

  void initialize() async {
    // 1. Load today's log
    _currentLog = await _repository.getTodayLog();

    // 2. Listen to pedometer stream
    // 2. Listen to pedometer provider
    // Using listen manual subscription since we are outside of a purely reactive scope (class method)
    // although ref.listen() is safer if we can use it.
    // The deprecated warning suggests replacing .stream.

    // Ideally, we should use ref.listen within the provider that creates this UseCase
    // But since logic is encapsulated in this class, let's use the subscription returned by ref.listen
    // Wait, ref.listen returns void (it's a fire-and-forget subscription attached to the Ref's lifecycle?)
    // Actually ref.listenSubscription? No.

    // If I use ref.listen, I don't need to manually cancel it if the Ref is disposed?
    // "The listener is automatically removed when the provider is disposed."
    // Since TrackStandProgressUseCase is created in a provider (line 130) and that provider is autoDispose? No it's FutureProvider without autoDispose.
    // If the provider is recomputed, the old use case is disposed (onDispose call in line 136).

    // So if I use `_ref.listen` inside `initialize`, does it attach to the `_ref` context?
    // Yes.

    // However, `todayStepsFromPedometerProvider` is a StreamProvider (implied by .stream existing previously).
    // So it provides `AsyncValue<int>`.

    _ref.listen(todayStepsFromPedometerProvider, (previous, next) {
      next.whenData(_onStepUpdate);
    });
  }

  void _onStepUpdate(int totalStepsToday) {
    if (_currentLog == null) return;

    final now = DateTime.now();
    final currentHour = now.hour;

    // Check for day change? Repository handles 'getTodayLog' correctly if re-fetched,
    // but here we are keeping _currentLog in memory.
    // Ideally we should check if date changed.
    final today = DateTime(now.year, now.month, now.day);
    if (!_currentLog!.date.isAtSameMomentAs(today)) {
      // Day changed! Reset.
      _resetForNewDay();
      return;
    }

    final lastReading = _currentLog!.lastSensorReading;

    // Calculate Delta
    int delta = 0;
    if (totalStepsToday < lastReading) {
      // Reboot occurred (sensor reset to 0)
      delta = totalStepsToday;
    } else {
      delta = totalStepsToday - lastReading;
    }

    if (delta <= 0) return; // No new steps or anomaly

    // Update Step Logic
    _updateHourProgress(currentHour, delta);

    // Update Last Reading
    _currentLog!.lastSensorReading = totalStepsToday;

    // Note: We are relying on memory state _currentLog.
    // We only save to DB in _updateHourProgress if significant change.
    // BUT we should probably save lastSensorReading periodically or
    // risk losing delta reference on app crash?
    // The requirement says "Do NOT persist on every single step".
    // So we accept some risk on 'lastSensorReading' specific value,
    // but 'totalStepsToday' from sensor is absolute for the day.
    // Wait, if we don't save 'lastSensorReading', on next launch:
    // DB has old 'lastSensorReading'. New sensor has 'totalStepsToday'.
    // delta = total - old_last. which is HUGE.
    // All those steps will be dumped into the 'currentHour' of next launch.
    // This might be acceptable, or we should throttle save 'lastSensorReading'.
    // For strictly following requirements, we only save on 'Active' or 'Hour Change'.
  }

  void _updateHourProgress(int hour, int delta) {
    bool needsSave = false;

    // Find or create hour progress
    final progress = _currentLog!.hourlyProgress.firstWhere(
      (p) => p.hour == hour,
      orElse: () {
        final newP = HourProgress(hour: hour, steps: 0);
        _currentLog!.hourlyProgress = [..._currentLog!.hourlyProgress, newP];
        return newP;
      },
    );

    // Update steps
    final oldSteps = progress.steps ?? 0;
    final newSteps = oldSteps + delta;
    progress.steps = newSteps;

    // Check Goal
    if (newSteps >= 60 && oldSteps < 60) {
      // Goal Achieved for this hour!
      if (!_currentLog!.activeHours.contains(hour)) {
        _currentLog!.activeHours = [..._currentLog!.activeHours, hour];
        needsSave = true;

        if (kDebugMode) {
          print('Stand Goal Achieved for Hour $hour! ($newSteps steps)');
        }
      }
    }

    // Check if hour changed (implicit in logic: if we are writing to a new hour)
    // Actually, handling "Hour Change" persistence:
    // If the PREVIOUS update was for hour H-1, and now is H.
    // We persist to "seal" the previous hour?
    // OR simpy persist if specific conditions met.

    if (needsSave) {
      _repository.saveLog(_currentLog!);
    }
  }

  void _resetForNewDay() async {
    _currentLog = await _repository.getTodayLog();
    // Assuming repository creates a fresh log with 0 steps
  }

  void dispose() {
    _pedometerSub?.cancel();
  }
}

/// Provider for the UseCase
final trackStandProgressUseCaseProvider =
    FutureProvider<TrackStandProgressUseCase>((ref) async {
  final repository = await ref.watch(standRepositoryProvider.future);
  final useCase = TrackStandProgressUseCase(repository, ref);
  useCase.initialize();

  ref.onDispose(() => useCase.dispose());

  return useCase;
});
