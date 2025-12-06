import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';

abstract class CommitmentRepository {
  Future<Either<Failure, List<FinancialCommitment>>> getAllCommitments();
  Future<Either<Failure, List<FinancialCommitment>>> getActiveCommitments();
  Future<Either<Failure, List<FinancialCommitment>>> getCompletedCommitments();
  Future<Either<Failure, FinancialCommitment?>> getCommitmentById(Id id);
  Future<Either<Failure, Id>> addCommitment(FinancialCommitment commitment);
  Future<Either<Failure, bool>> updateCommitment(
    FinancialCommitment commitment,
  );
  Future<Either<Failure, bool>> deleteCommitment(Id id);

  // Contribution methods
  Future<Either<Failure, List<CommitmentContribution>>>
      getContributionsByCommitment(Id commitmentId);
  Future<Either<Failure, Id>> addContribution(
    CommitmentContribution contribution,
  );
  Future<Either<Failure, bool>> updateContribution(
    CommitmentContribution contribution,
  );
  Future<Either<Failure, bool>> deleteContribution(Id id);
}
