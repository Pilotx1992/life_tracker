import 'package:life_tracker/features/health/domain/entities/activity_summary.dart';

abstract class ActivityRepository {
  /// Get a stream of activity data that updates in real-time.
  /// The repository decides the best source (Phone vs Health Connect) based on data recency and availability.
  Stream<ActivitySummary> getActivityStream();

  /// Force a refresh of data (e.g., sync from Health Connect)
  Future<void> refresh();
}
