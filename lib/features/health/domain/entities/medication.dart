import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Medication extends Equatable {
  final Id? id;
  final String name;
  final String dosage;
  final List<DateTime> times;
  final String? instructions;
  final DateTime startDate;
  final DateTime? endDate;

  const Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.times,
    this.instructions,
    required this.startDate,
    this.endDate,
  });

  bool get isActive => endDate == null || endDate!.isAfter(DateTime.now());

  @override
  List<Object?> get props =>
      [id, name, dosage, times, instructions, startDate, endDate];

  Medication copyWith({
    Id? id,
    String? name,
    String? dosage,
    List<DateTime>? times,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
