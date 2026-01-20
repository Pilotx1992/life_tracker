import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/providers/database_provider.dart';
import 'package:life_tracker/features/health/data/models/daily_stand_log.dart';

/// Interface for Stand Repository
abstract class StandRepository {
  Future<DailyStandLog> getTodayLog();
  Future<void> saveLog(DailyStandLog log);
  Stream<DailyStandLog?> watchTodayLog();
}

/// Implementation using Isar
class IsarStandRepository implements StandRepository {
  final Isar _isar;

  IsarStandRepository(this._isar);

  @override
  Future<DailyStandLog> getTodayLog() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final log =
        await _isar.dailyStandLogs.filter().dateEqualTo(today).findFirst();

    if (log != null) return log;

    // Create new log if not exists
    return DailyStandLog()
      ..date = today
      ..activeHours = []
      ..hourlyProgress = []
      ..lastSensorReading = 0;
  }

  @override
  Future<void> saveLog(DailyStandLog log) async {
    await _isar.writeTxn(() async {
      await _isar.dailyStandLogs.put(log);
    });
  }

  @override
  Stream<DailyStandLog?> watchTodayLog() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _isar.dailyStandLogs
        .filter()
        .dateEqualTo(today)
        .watch(fireImmediately: true)
        .map((logs) => logs.isNotEmpty ? logs.first : null);
  }
}

/// Provider for the repository
final standRepositoryProvider = FutureProvider<StandRepository>((ref) async {
  final isar = await ref.watch(databaseProvider.future);
  return IsarStandRepository(isar);
});
