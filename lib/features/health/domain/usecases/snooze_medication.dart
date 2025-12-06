import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class SnoozeMedication implements UseCase<bool, SnoozeMedicationParams> {
  final MedicationRepository repository;

  SnoozeMedication(this.repository);

  @override
  Future<Either<Failure, bool>> call(SnoozeMedicationParams params) async {
    // For now, snoozing means updating the scheduled time of the intake.
    // In a real app, this might involve creating a new intake entry or more complex logic.
    final intake = MedicationIntake(
      id: params.intakeId,
      medicationId: params.medicationId,
      scheduledTime: params.newScheduledTime,
      actualTakenTime: null,
      isTaken: false,
    );
    return await repository.updateMedicationIntake(intake);
  }
}

class SnoozeMedicationParams extends Equatable {
  final Id intakeId;
  final int medicationId;
  final DateTime newScheduledTime;

  const SnoozeMedicationParams({
    required this.intakeId,
    required this.medicationId,
    required this.newScheduledTime,
  });

  @override
  List<Object?> get props => [intakeId, medicationId, newScheduledTime];
}
