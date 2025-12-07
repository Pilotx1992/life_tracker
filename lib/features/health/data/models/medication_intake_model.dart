import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';

part 'medication_intake_model.g.dart';

@collection
class MedicationIntakeModel {
  Id id = Isar.autoIncrement;
  @Index()
  late int medicationId; // Link to Medication
  @Index()
  late DateTime scheduledTime;
  DateTime? actualTakenTime;
  bool isTaken;

  MedicationIntakeModel({
    required this.medicationId,
    required this.scheduledTime,
    this.actualTakenTime,
    this.isTaken = false,
  });

  MedicationIntake toEntity() {
    return MedicationIntake(
      id: id,
      medicationId: medicationId,
      scheduledTime: scheduledTime,
      actualTakenTime: actualTakenTime,
      isTaken: isTaken,
    );
  }

  factory MedicationIntakeModel.fromEntity(MedicationIntake entity) {
    return MedicationIntakeModel(
      medicationId: entity.medicationId,
      scheduledTime: entity.scheduledTime,
      actualTakenTime: entity.actualTakenTime,
      isTaken: entity.isTaken,
    ).copyWith(id: entity.id);
  }

  MedicationIntakeModel copyWith({
    Id? id,
    Id? medicationId,
    DateTime? scheduledTime,
    DateTime? actualTakenTime,
    bool? isTaken,
  }) {
    return MedicationIntakeModel(
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTakenTime: actualTakenTime ?? this.actualTakenTime,
      isTaken: isTaken ?? this.isTaken,
    )..id = id ?? this.id;
  }
}
