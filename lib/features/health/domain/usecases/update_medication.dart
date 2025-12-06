import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class UpdateMedication implements UseCase<bool, Medication> {
  final MedicationRepository repository;

  UpdateMedication(this.repository);

  @override
  Future<Either<Failure, bool>> call(Medication params) async {
    return await repository.updateMedication(params);
  }
}
