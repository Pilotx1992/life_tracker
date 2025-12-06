import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class WeightEntry extends Equatable {
  final Id? id;
  final double weight;
  final DateTime date;
  final String? note;

  const WeightEntry({
    this.id,
    required this.weight,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, weight, date, note];

  WeightEntry copyWith({
    Id? id,
    double? weight,
    DateTime? date,
    String? note,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
