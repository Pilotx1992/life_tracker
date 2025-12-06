import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/domain/entities/sleep_entry.dart';

/// Provider for Sleep data
/// TODO: Implement full repository pattern when data layer is ready
final sleepListProvider = Provider<List<SleepEntry>>((ref) {
  // Mock data for now - will be replaced with real data source
  return [];
});

/// Provider for average sleep hours (last 7 days)
final averageSleepHoursProvider = Provider<double?>((ref) {
  final sleepEntries = ref.watch(sleepListProvider);
  if (sleepEntries.isEmpty) return null;

  final last7Days = sleepEntries.where((entry) {
    return entry.date.isAfter(
      DateTime.now().subtract(const Duration(days: 7)),
    );
  }).toList();

  if (last7Days.isEmpty) return null;

  final totalHours = last7Days.map((e) => e.hours).reduce((a, b) => a + b);

  return totalHours / last7Days.length;
});

/// Provider for last night's sleep
final lastNightSleepProvider = Provider<SleepEntry?>((ref) {
  final sleepEntries = ref.watch(sleepListProvider);
  if (sleepEntries.isEmpty) return null;

  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final yesterdayStart =
      DateTime(yesterday.year, yesterday.month, yesterday.day);
  final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));

  return sleepEntries.firstWhere(
    (entry) =>
        entry.date.isAfter(yesterdayStart) && entry.date.isBefore(yesterdayEnd),
    orElse: () => sleepEntries.first,
  );
});
