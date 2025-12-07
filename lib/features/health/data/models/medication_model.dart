import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';

part 'medication_model.g.dart';

@collection
class MedicationModel {
  Id id = Isar.autoIncrement;
  late String name;
  late String dosage;
  late List<DateTime> times;
  String? instructions;
  @Index()
  late DateTime startDate;
  @Index()
  DateTime? endDate;

  MedicationModel({
    required this.name,
    required this.dosage,
    required this.times,
    this.instructions,
    required this.startDate,
    this.endDate,
  });

  Medication toEntity() {
    return Medication(
      id: id,
      name: name,
      dosage: dosage,
      times: times,
      instructions: instructions,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory MedicationModel.fromEntity(Medication entity) {
    return MedicationModel(
      name: entity.name,
      dosage: entity.dosage,
      times: entity.times,
      instructions: entity.instructions,
      startDate: entity.startDate,
      endDate: entity.endDate,
    ).copyWith(id: entity.id);
  }

  MedicationModel copyWith({
    Id? id,
    String? name,
    String? dosage,
    List<DateTime>? times,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MedicationModel(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    )..id = id ?? this.id;
  }
}
