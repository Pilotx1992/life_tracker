import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class GetCompletedCommitments
    implements UseCase<List<FinancialCommitment>, NoParams> {
  final CommitmentRepository repository;

  GetCompletedCommitments(this.repository);

  @override
  Future<Either<Failure, List<FinancialCommitment>>> call(
    NoParams params,
  ) async {
    return await repository.getCompletedCommitments();
  }
}
