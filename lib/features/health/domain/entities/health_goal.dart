import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class HealthGoal extends Equatable {
  final Id? id;
  final String type; // steps, calories, distance, sleep, weight, etc.
  final double target; // Target value
  final double current; // Current value
  final String period; // daily, weekly, monthly
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const HealthGoal({
    this.id,
    required this.type,
    required this.target,
    this.current = 0.0,
    this.period = 'daily',
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        target,
        current,
        period,
        startDate,
        endDate,
        isActive,
      ];

  HealthGoal copyWith({
    Id? id,
    String? type,
    double? target,
    double? current,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return HealthGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  double get progress => (current / target).clamp(0.0, 1.0);
  double get percentage => progress * 100;
}
