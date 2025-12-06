import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class DeleteCommitment implements UseCase<bool, Id> {
  final CommitmentRepository repository;

  DeleteCommitment(this.repository);

  @override
  Future<Either<Failure, bool>> call(Id params) async {
    return await repository.deleteCommitment(params);
  }
}
