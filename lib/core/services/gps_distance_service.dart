import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Service for tracking distance using GPS
/// Automatically handles permission checks and provides distance calculation
class GpsDistanceService {
  static final GpsDistanceService _instance = GpsDistanceService._internal();
  factory GpsDistanceService() => _instance;
  GpsDistanceService._internal();

  // Stream controller for distance updates
  final StreamController<double> _distanceController =
      StreamController<double>.broadcast();

  // State
  Position? _lastPosition;
  double _totalDistanceMeters = 0.0;
  DateTime? _lastResetDate;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;

  /// Stream of today's distance in meters
  Stream<double> get distanceStream => _distanceController.stream;

  /// Current total distance in meters for today
  double get todayDistanceMeters => _totalDistanceMeters;

  /// Current total distance in kilometers for today
  double get todayDistanceKm => _totalDistanceMeters / 1000.0;

  /// Whether GPS tracking is currently active
  bool get isTracking => _isTracking;

  /// Check if GPS is available and permission is granted
  Future<bool> isGpsAvailable() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize the GPS service
  Future<void> initialize() async {
    await _checkDayReset();
  }

  /// Start GPS tracking
  Future<bool> startTracking() async {
    if (_isTracking) return true;

    final available = await isGpsAvailable();
    if (!available) return false;

    try {
      // Check for day reset
      await _checkDayReset();

      // Get initial position
      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Minimum 5 meters before update
        ),
      );

      // Start listening to position updates
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters
        ),
      ).listen(_onPositionUpdate);

      _isTracking = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop GPS tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
  }

  /// Handle position updates
  void _onPositionUpdate(Position position) {
    if (_lastPosition != null) {
      // Calculate distance from last position using Haversine formula
      final distance = _calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Only add if movement is significant (>2 meters) and speed is reasonable
      // This filters out GPS drift and unrealistic speeds
      if (distance > 2 && position.speed < 50) {
        // < 180 km/h
        _totalDistanceMeters += distance;
        _distanceController.add(_totalDistanceMeters);
      }
    }

    _lastPosition = position;
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // Earth's radius in meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  /// Check if we need to reset for a new day
  Future<void> _checkDayReset() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null || _lastResetDate!.isBefore(todayStart)) {
      // New day - reset distance
      _totalDistanceMeters = 0.0;
      _lastResetDate = todayStart;
      _lastPosition = null;
      _distanceController.add(0.0);
    }
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
    _distanceController.close();
  }
}
