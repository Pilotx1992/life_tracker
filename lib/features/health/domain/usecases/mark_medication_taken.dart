import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class MarkMedicationTaken implements UseCase<bool, MarkMedicationTakenParams> {
  final MedicationRepository repository;

  MarkMedicationTaken(this.repository);

  @override
  Future<Either<Failure, bool>> call(MarkMedicationTakenParams params) async {
    final intake = MedicationIntake(
      id: params.intakeId,
      medicationId: params.medicationId,
      scheduledTime: params.scheduledTime,
      actualTakenTime: params.actualTakenTime ?? DateTime.now(),
      isTaken: true,
    );
    return await repository.updateMedicationIntake(intake);
  }
}

class MarkMedicationTakenParams extends Equatable {
  final Id intakeId;
  final int medicationId;
  final DateTime scheduledTime;
  final DateTime? actualTakenTime;

  const MarkMedicationTakenParams({
    required this.intakeId,
    required this.medicationId,
    required this.scheduledTime,
    this.actualTakenTime,
  });

  @override
  List<Object?> get props =>
      [intakeId, medicationId, scheduledTime, actualTakenTime];
}
