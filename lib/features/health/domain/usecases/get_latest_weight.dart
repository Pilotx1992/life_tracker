import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';

class GetLatestWeight implements UseCase<WeightEntry, NoParams> {
  final WeightRepository repository;

  GetLatestWeight(this.repository);

  @override
  Future<Either<Failure, WeightEntry>> call(NoParams params) async {
    return await repository.getLatestWeight();
  }
}
