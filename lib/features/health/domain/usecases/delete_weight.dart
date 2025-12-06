import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';

class DeleteWeight implements UseCase<bool, Id> {
  final WeightRepository repository;

  DeleteWeight(this.repository);

  @override
  Future<Either<Failure, bool>> call(Id params) async {
    return await repository.deleteWeight(params);
  }
}
