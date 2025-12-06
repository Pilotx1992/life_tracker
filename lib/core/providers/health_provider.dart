import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/health_service.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/usecases/get_weights.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';

/// State for Health Connect
class HealthConnectState {
  final bool isAuthorized;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final List<WeightDataPoint> weightData;
  final List<StepsDataPoint> stepsData;
  final List<HeartRateDataPoint> heartRateData;
  final String? error;

  HealthConnectState({
    this.isAuthorized = false,
    this.isSyncing = false,
    this.lastSyncTime,
    this.weightData = const [],
    this.stepsData = const [],
    this.heartRateData = const [],
    this.error,
  });

  HealthConnectState copyWith({
    bool? isAuthorized,
    bool? isSyncing,
    DateTime? lastSyncTime,
    List<WeightDataPoint>? weightData,
    List<StepsDataPoint>? stepsData,
    List<HeartRateDataPoint>? heartRateData,
    String? error,
  }) {
    return HealthConnectState(
      isAuthorized: isAuthorized ?? this.isAuthorized,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      weightData: weightData ?? this.weightData,
      stepsData: stepsData ?? this.stepsData,
      heartRateData: heartRateData ?? this.heartRateData,
      error: error ?? this.error,
    );
  }
}

/// Notifier for Health Connect
class HealthConnectNotifier extends StateNotifier<HealthConnectState> {
  final HealthService _healthService;
  final Ref _ref;
  Timer? _autoSyncTimer;
  static const Duration _autoSyncInterval =
      Duration(hours: 6); // Sync every 6 hours

  HealthConnectNotifier(this._healthService, this._ref)
      : super(HealthConnectState()) {
    _checkPermissions();
    _startAutoSync();
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermissions = await _healthService.hasPermissions();
      state = state.copyWith(isAuthorized: hasPermissions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> requestPermissions() async {
    try {
      state = state.copyWith(error: null);
      final granted = await _healthService.requestPermissions();
      state = state.copyWith(isAuthorized: granted);
      return granted;
    } catch (e) {
      state = state.copyWith(
        isAuthorized: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> syncWeightData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!state.isAuthorized) {
      state = state.copyWith(error: 'Health permissions not granted');
      return;
    }

    try {
      state = state.copyWith(isSyncing: true, error: null);

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final weightData = await _healthService.readWeightData(
        startDate: start,
        endDate: end,
      );

      state = state.copyWith(
        isSyncing: false,
        weightData: weightData,
        lastSyncTime: DateTime.now(),
      );

      // Auto-save weight data to local database
      await _saveWeightDataToLocalDB(weightData);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> syncStepsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!state.isAuthorized) {
      state = state.copyWith(error: 'Health permissions not granted');
      return;
    }

    try {
      state = state.copyWith(isSyncing: true, error: null);

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();

      final stepsData = await _healthService.readStepsData(
        startDate: start,
        endDate: end,
      );

      state = state.copyWith(
        isSyncing: false,
        stepsData: stepsData,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> syncHeartRateData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!state.isAuthorized) {
      state = state.copyWith(error: 'Health permissions not granted');
      return;
    }

    try {
      state = state.copyWith(isSyncing: true, error: null);

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();

      final heartRateData = await _healthService.readHeartRateData(
        startDate: start,
        endDate: end,
      );

      state = state.copyWith(
        isSyncing: false,
        heartRateData: heartRateData,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> syncAllData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!state.isAuthorized) {
      state = state.copyWith(error: 'Health permissions not granted');
      return;
    }

    try {
      state = state.copyWith(isSyncing: true, error: null);

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Sync all data types concurrently
      final results = await Future.wait([
        _healthService.readWeightData(startDate: start, endDate: end),
        _healthService.readStepsData(startDate: start, endDate: end),
        _healthService.readHeartRateData(startDate: start, endDate: end),
      ]);

      state = state.copyWith(
        isSyncing: false,
        weightData: results[0] as List<WeightDataPoint>,
        stepsData: results[1] as List<StepsDataPoint>,
        heartRateData: results[2] as List<HeartRateDataPoint>,
        lastSyncTime: DateTime.now(),
      );

      // Auto-save weight data to local database
      await _saveWeightDataToLocalDB(results[0] as List<WeightDataPoint>);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  /// Save weight data from Health Connect to local database
  /// Only saves new entries that don't already exist (based on date and weight)
  Future<void> _saveWeightDataToLocalDB(
    List<WeightDataPoint> weightData,
  ) async {
    try {
      // Get existing weights from local database
      final existingWeightsResult = await _ref.read(getWeightsUseCaseProvider)(
        const GetWeightsParams(),
      );

      final existingWeights = existingWeightsResult.fold(
        (failure) => <WeightEntry>[],
        (weights) => weights,
      );

      // Create a set of existing weight entries (date + weight) for quick lookup
      final existingEntries = <String>{};
      for (final weight in existingWeights) {
        // Use date (without time) + weight as key to avoid duplicates
        final dateKey = DateTime(
          weight.date.year,
          weight.date.month,
          weight.date.day,
        );
        existingEntries.add(
          '${dateKey.toIso8601String()}_${weight.weight.toStringAsFixed(1)}',
        );
      }

      // Save new weight entries
      for (final dataPoint in weightData) {
        // Check if this entry already exists
        final dateKey = DateTime(
          dataPoint.date.year,
          dataPoint.date.month,
          dataPoint.date.day,
        );
        final entryKey =
            '${dateKey.toIso8601String()}_${dataPoint.weight.toStringAsFixed(1)}';

        if (!existingEntries.contains(entryKey)) {
          final weightEntry = WeightEntry(
            weight: dataPoint.weight,
            date: dataPoint.date,
          );

          await _ref
              .read(weightNotifierProvider.notifier)
              .addWeightEntry(weightEntry);
        }
      }

      // Note: We don't show a message here to avoid interrupting the user
      // The data is saved silently in the background
    } catch (e) {
      // Silently handle errors - don't interrupt the sync process
      // Errors are already handled in the state
    }
  }

  /// Start automatic periodic sync
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
      if (state.isAuthorized && !state.isSyncing) {
        syncAllData(
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          endDate: DateTime.now(),
        );
      }
    });
  }

  /// Stop automatic periodic sync
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Restart automatic periodic sync
  void restartAutoSync() {
    _startAutoSync();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}

/// Provider for Health Connect state
final healthConnectProvider =
    StateNotifierProvider<HealthConnectNotifier, HealthConnectState>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return HealthConnectNotifier(healthService, ref);
});
