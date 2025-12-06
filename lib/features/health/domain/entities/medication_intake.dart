import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class MedicationIntake extends Equatable {
  final Id? id;
  final int medicationId;
  final DateTime scheduledTime;
  final DateTime? actualTakenTime;
  final bool isTaken;

  const MedicationIntake({
    this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.actualTakenTime,
    this.isTaken = false,
  });

  @override
  List<Object?> get props =>
      [id, medicationId, scheduledTime, actualTakenTime, isTaken];

  MedicationIntake copyWith({
    Id? id,
    Id? medicationId,
    DateTime? scheduledTime,
    DateTime? actualTakenTime,
    bool? isTaken,
  }) {
    return MedicationIntake(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTakenTime: actualTakenTime ?? this.actualTakenTime,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
