import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';

part 'weight_model.g.dart';

@collection
class WeightModel {
  Id id = Isar.autoIncrement;
  late double weight;
  @Index()
  late DateTime date;
  String? note;

  WeightModel({
    required this.weight,
    required this.date,
    this.note,
  });

  // Convert WeightModel to WeightEntry entity
  WeightEntry toEntity() {
    return WeightEntry(
      id: id,
      weight: weight,
      date: date,
      note: note,
    );
  }

  // Create WeightModel from WeightEntry entity
  factory WeightModel.fromEntity(WeightEntry entity) {
    return WeightModel(
      weight: entity.weight,
      date: entity.date,
      note: entity.note,
    ).copyWith(id: entity.id);
  }

  // Helper to copy with new values, especially for ID during updates
  WeightModel copyWith({
    Id? id,
    double? weight,
    DateTime? date,
    String? note,
  }) {
    return WeightModel(
      weight: weight ?? this.weight,
      date: date ?? this.date,
      note: note ?? this.note,
    )..id = id ?? this.id;
  }
}
