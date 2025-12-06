import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class GetMedicationIntakes
    implements UseCase<List<MedicationIntake>, GetMedicationIntakesParams> {
  final MedicationRepository repository;

  GetMedicationIntakes(this.repository);

  @override
  Future<Either<Failure, List<MedicationIntake>>> call(
    GetMedicationIntakesParams params,
  ) async {
    return await repository
        .getMedicationIntakesForMedication(params.medicationId);
  }
}

class GetMedicationIntakesParams extends Equatable {
  final Id medicationId;

  const GetMedicationIntakesParams({required this.medicationId});

  @override
  List<Object?> get props => [medicationId];
}
