import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class WorkoutEntry extends Equatable {
  final Id? id;
  final String type; // Running, Cycling, Walking, etc.
  final DateTime date;
  final Duration duration;
  final double? calories; // Calories burned
  final double? distance; // Distance in km
  final double? averageHeartRate;
  final String? note;

  const WorkoutEntry({
    this.id,
    required this.type,
    required this.date,
    required this.duration,
    this.calories,
    this.distance,
    this.averageHeartRate,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        date,
        duration,
        calories,
        distance,
        averageHeartRate,
        note,
      ];

  WorkoutEntry copyWith({
    Id? id,
    String? type,
    DateTime? date,
    Duration? duration,
    double? calories,
    double? distance,
    double? averageHeartRate,
    String? note,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      distance: distance ?? this.distance,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      note: note ?? this.note,
    );
  }

  double get minutes => duration.inMinutes.toDouble();
}
