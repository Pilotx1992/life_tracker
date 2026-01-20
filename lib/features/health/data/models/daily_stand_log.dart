import 'package:isar/isar.dart';

part 'daily_stand_log.g.dart';

@collection
class DailyStandLog {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime date;

  /// List of hours (0-23) where the user achieved the stand goal
  List<int> activeHours = [];

  /// Detailed progress for each hour to track steps between sessions
  List<HourProgress> hourlyProgress = [];

  /// The last raw sensor reading processed, used to calculate deltas
  int lastSensorReading = 0;
}

@embedded
class HourProgress {
  int? hour; // 0-23
  int? steps;

  HourProgress({this.hour, this.steps});
}
