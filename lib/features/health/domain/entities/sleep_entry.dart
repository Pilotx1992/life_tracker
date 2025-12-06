import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class SleepEntry extends Equatable {
  final Id? id;
  final DateTime date;
  final Duration duration; // Total sleep duration
  final int? quality; // 1-10 quality rating
  final Duration? deepSleep; // Deep sleep duration
  final Duration? lightSleep; // Light sleep duration
  final String? note;

  const SleepEntry({
    this.id,
    required this.date,
    required this.duration,
    this.quality,
    this.deepSleep,
    this.lightSleep,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        duration,
        quality,
        deepSleep,
        lightSleep,
        note,
      ];

  SleepEntry copyWith({
    Id? id,
    DateTime? date,
    Duration? duration,
    int? quality,
    Duration? deepSleep,
    Duration? lightSleep,
    String? note,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      deepSleep: deepSleep ?? this.deepSleep,
      lightSleep: lightSleep ?? this.lightSleep,
      note: note ?? this.note,
    );
  }

  double get hours => duration.inMinutes / 60.0;
}
