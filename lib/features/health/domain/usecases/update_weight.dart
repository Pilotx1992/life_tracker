import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';

class UpdateWeight implements UseCase<bool, WeightEntry> {
  final WeightRepository repository;

  UpdateWeight(this.repository);

  @override
  Future<Either<Failure, bool>> call(WeightEntry params) async {
    return await repository.updateWeight(params);
  }
}
