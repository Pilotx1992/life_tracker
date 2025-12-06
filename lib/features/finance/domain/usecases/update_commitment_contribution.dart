import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class UpdateCommitmentContribution
    implements UseCase<bool, CommitmentContribution> {
  final CommitmentRepository repository;

  UpdateCommitmentContribution(this.repository);

  @override
  Future<Either<Failure, bool>> call(CommitmentContribution params) async {
    return await repository.updateContribution(params);
  }
}
