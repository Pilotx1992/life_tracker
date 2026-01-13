import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/gps_distance_service.dart';

/// Provider for GpsDistanceService singleton
final gpsDistanceServiceProvider = Provider<GpsDistanceService>((ref) {
  final service = GpsDistanceService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for GPS availability status
final gpsAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(gpsDistanceServiceProvider);
  return service.isGpsAvailable();
});

/// Provider for GPS tracking status
final gpsTrackingProvider = Provider<bool>((ref) {
  final service = ref.watch(gpsDistanceServiceProvider);
  return service.isTracking;
});

/// Provider for GPS distance stream (in meters)
final gpsDistanceStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(gpsDistanceServiceProvider);
  return service.distanceStream;
});

/// Provider for current GPS distance (synchronous access, in km)
final currentGpsDistanceKmProvider = Provider<double>((ref) {
  final asyncDistance = ref.watch(gpsDistanceStreamProvider);
  return asyncDistance.when(
    data: (meters) => meters / 1000.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
