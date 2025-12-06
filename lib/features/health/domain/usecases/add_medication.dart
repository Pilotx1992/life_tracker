import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class AddMedication implements UseCase<Id, Medication> {
  final MedicationRepository repository;

  AddMedication(this.repository);

  @override
  Future<Either<Failure, Id>> call(Medication params) async {
    return await repository.addMedication(params);
  }
}
