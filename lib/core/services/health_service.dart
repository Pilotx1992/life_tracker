import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing Health Connect integration with smart watches and fitness apps.
///
/// Supports reading:
/// - Weight data
/// - Steps count
/// - Heart rate
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  Health? _health;
  bool _isAuthorized = false;

  final StreamController<List<HealthDataPoint>> _healthDataController =
      StreamController<List<HealthDataPoint>>.broadcast();

  /// Stream of health data points
  Stream<List<HealthDataPoint>> get healthDataStream =>
      _healthDataController.stream;

  /// Initialize Health Connect
  Future<void> initialize() async {
    _health = Health();
  }

  /// Request permissions for health data
  Future<bool> requestPermissions() async {
    if (_health == null) {
      await initialize();
    }

    try {
      // Request activity recognition permission first (required for Android)
      final activityStatus = await Permission.activityRecognition.request();
      if (!activityStatus.isGranted) {
        return false;
      }

      // Define the types of health data we want to read
      final types = [
        HealthDataType.WEIGHT,
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_DELTA,
      ];

      // Request permissions
      final permissions = types.map((type) => HealthDataAccess.READ).toList();

      _isAuthorized =
          await _health!.requestAuthorization(types, permissions: permissions);

      return _isAuthorized;
    } catch (e) {
      return false;
    }
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    if (_health == null) {
      await initialize();
    }

    try {
      final types = [
        HealthDataType.WEIGHT,
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ];

      _isAuthorized = await _health!.hasPermissions(types) ?? false;
      return _isAuthorized;
    } catch (e) {
      return false;
    }
  }

  /// Read weight data from Health Connect
  ///
  /// Returns list of weight measurements in kg
  Future<List<WeightDataPoint>> readWeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null) {
      await initialize();
    }

    if (!_isAuthorized) {
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        throw Exception('Health permissions not granted');
      }
    }

    try {
      final types = [HealthDataType.WEIGHT];

      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: startDate,
        endTime: endDate,
      );

      final weightData = healthData
          .where((data) => data.type == HealthDataType.WEIGHT)
          .map(
            (data) => WeightDataPoint(
              weight:
                  (data.value as NumericHealthValue).numericValue.toDouble(),
              date: data.dateFrom,
              source: data.sourceName,
            ),
          )
          .toList();

      // Sort by date (newest first)
      weightData.sort((a, b) => b.date.compareTo(a.date));

      return weightData;
    } catch (e) {
      throw Exception('Failed to read weight data: $e');
    }
  }

  /// Read steps data from Health Connect
  Future<List<StepsDataPoint>> readStepsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null) {
      await initialize();
    }

    if (!_isAuthorized) {
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        throw Exception('Health permissions not granted');
      }
    }

    try {
      final types = [HealthDataType.STEPS];

      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: startDate,
        endTime: endDate,
      );

      final stepsData = healthData
          .where((data) => data.type == HealthDataType.STEPS)
          .map(
            (data) => StepsDataPoint(
              steps: (data.value as NumericHealthValue).numericValue.toInt(),
              date: data.dateFrom,
              source: data.sourceName,
            ),
          )
          .toList();

      // Sort by date (newest first)
      stepsData.sort((a, b) => b.date.compareTo(a.date));

      return stepsData;
    } catch (e) {
      throw Exception('Failed to read steps data: $e');
    }
  }

  /// Read heart rate data from Health Connect
  Future<List<HeartRateDataPoint>> readHeartRateData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null) {
      await initialize();
    }

    if (!_isAuthorized) {
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        throw Exception('Health permissions not granted');
      }
    }

    try {
      final types = [HealthDataType.HEART_RATE];

      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: startDate,
        endTime: endDate,
      );

      final heartRateData = healthData
          .where((data) => data.type == HealthDataType.HEART_RATE)
          .map(
            (data) => HeartRateDataPoint(
              heartRate:
                  (data.value as NumericHealthValue).numericValue.toInt(),
              date: data.dateFrom,
              source: data.sourceName,
            ),
          )
          .toList();

      // Sort by date (newest first)
      heartRateData.sort((a, b) => b.date.compareTo(a.date));

      return heartRateData;
    } catch (e) {
      throw Exception('Failed to read heart rate data: $e');
    }
  }

  /// Read active energy data from Health Connect
  Future<List<ActiveEnergyDataPoint>> readActiveEnergyData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null) await initialize();
    if (!_isAuthorized) {
      if (!await hasPermissions())
        throw Exception('Health permissions not granted');
    }

    try {
      final types = [HealthDataType.ACTIVE_ENERGY_BURNED];
      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: startDate,
        endTime: endDate,
      );

      final energyData = healthData
          .where((data) => data.type == HealthDataType.ACTIVE_ENERGY_BURNED)
          .map((data) => ActiveEnergyDataPoint(
                calories:
                    (data.value as NumericHealthValue).numericValue.toDouble(),
                date: data.dateFrom,
                source: data.sourceName,
              ))
          .toList();

      energyData.sort((a, b) => b.date.compareTo(a.date));
      return energyData;
    } catch (e) {
      throw Exception('Failed to read active energy data: $e');
    }
  }

  /// Read distance data from Health Connect
  Future<List<DistanceDataPoint>> readDistanceData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null) await initialize();
    if (!_isAuthorized) {
      if (!await hasPermissions())
        throw Exception('Health permissions not granted');
    }

    try {
      final types = [HealthDataType.DISTANCE_DELTA];
      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: startDate,
        endTime: endDate,
      );

      final distanceData = healthData
          .where((data) => data.type == HealthDataType.DISTANCE_DELTA)
          .map((data) => DistanceDataPoint(
                distance:
                    (data.value as NumericHealthValue).numericValue.toDouble(),
                date: data.dateFrom,
                source: data.sourceName,
              ))
          .toList();

      distanceData.sort((a, b) => b.date.compareTo(a.date));
      return distanceData;
    } catch (e) {
      throw Exception('Failed to read distance data: $e');
    }
  }

  /// Sync all health data
  Future<void> syncAllData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final types = [
      HealthDataType.WEIGHT,
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.DISTANCE_DELTA,
    ];

    try {
      final healthData = await _health!.getHealthDataFromTypes(
        types: types,
        startTime: startDate,
        endTime: endDate,
      );

      _healthDataController.add(healthData);
    } catch (e) {
      throw Exception('Failed to sync health data: $e');
    }
  }

  /// Dispose all resources
  void dispose() {
    _healthDataController.close();
  }
}

/// Data class for weight measurements
class WeightDataPoint {
  final double weight; // in kg
  final DateTime date;
  final String source;

  WeightDataPoint({
    required this.weight,
    required this.date,
    required this.source,
  });
}

/// Data class for steps count
class StepsDataPoint {
  final int steps;
  final DateTime date;
  final String source;

  StepsDataPoint({
    required this.steps,
    required this.date,
    required this.source,
  });
}

/// Data class for heart rate
class HeartRateDataPoint {
  final int heartRate; // bpm
  final DateTime date;
  final String source;

  HeartRateDataPoint({
    required this.heartRate,
    required this.date,
    required this.source,
  });
}

/// Data class for active energy (calories)
class ActiveEnergyDataPoint {
  final double calories; // kcal
  final DateTime date;
  final String source;

  ActiveEnergyDataPoint({
    required this.calories,
    required this.date,
    required this.source,
  });
}

/// Data class for distance
class DistanceDataPoint {
  final double distance; // meters
  final DateTime date;
  final String source;

  DistanceDataPoint({
    required this.distance,
    required this.date,
    required this.source,
  });
}

/// Provider for Health Service
final healthServiceProvider = Provider<HealthService>((ref) {
  final service = HealthService();
  ref.onDispose(() => service.dispose());
  return service;
});
