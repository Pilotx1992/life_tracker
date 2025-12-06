import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';

class AddWeight implements UseCase<Id, WeightEntry> {
  final WeightRepository repository;

  AddWeight(this.repository);

  @override
  Future<Either<Failure, Id>> call(WeightEntry params) async {
    return await repository.addWeight(params);
  }
}
