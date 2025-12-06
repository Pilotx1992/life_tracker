import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class CalculateAdherence implements UseCase<double, Id> {
  final MedicationRepository repository;

  CalculateAdherence(this.repository);

  @override
  Future<Either<Failure, double>> call(Id params) async {
    return await repository.calculateAdherence(params);
  }
}
