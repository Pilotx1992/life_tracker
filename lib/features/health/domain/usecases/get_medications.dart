import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class GetMedications
    implements UseCase<List<Medication>, GetMedicationsParams> {
  final MedicationRepository repository;

  GetMedications(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(
    GetMedicationsParams params,
  ) async {
    if (params.onlyActive) {
      return await repository.getActiveMedications();
    } else {
      return await repository.getAllMedications();
    }
  }
}

class GetMedicationsParams extends Equatable {
  final bool onlyActive;

  const GetMedicationsParams({this.onlyActive = false});

  @override
  List<Object?> get props => [onlyActive];
}
