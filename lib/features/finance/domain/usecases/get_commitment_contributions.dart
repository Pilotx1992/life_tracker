import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class GetCommitmentContributions
    implements UseCase<List<CommitmentContribution>, Id> {
  final CommitmentRepository repository;

  GetCommitmentContributions(this.repository);

  @override
  Future<Either<Failure, List<CommitmentContribution>>> call(Id params) async {
    return await repository.getContributionsByCommitment(params);
  }
}
