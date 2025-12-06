import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/commitment_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/financial_commitment_model.dart';
import 'package:life_tracker/features/finance/data/models/commitment_contribution_model.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class CommitmentRepositoryImpl implements CommitmentRepository {
  final CommitmentLocalDataSource localDataSource;

  CommitmentRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<FinancialCommitment>>> getAllCommitments() async {
    try {
      final commitmentModels = await localDataSource.getAllCommitments();
      final commitments =
          commitmentModels.map((model) => model.toEntity()).toList();
      return Right(commitments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FinancialCommitment>>>
      getActiveCommitments() async {
    try {
      final commitmentModels = await localDataSource.getActiveCommitments();
      final commitments =
          commitmentModels.map((model) => model.toEntity()).toList();
      return Right(commitments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FinancialCommitment>>>
      getCompletedCommitments() async {
    try {
      final commitmentModels = await localDataSource.getCompletedCommitments();
      final commitments =
          commitmentModels.map((model) => model.toEntity()).toList();
      return Right(commitments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, FinancialCommitment?>> getCommitmentById(Id id) async {
    try {
      final commitmentModel = await localDataSource.getCommitmentById(id);
      return Right(commitmentModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addCommitment(
    FinancialCommitment commitment,
  ) async {
    try {
      final commitmentModel = FinancialCommitmentModel.fromEntity(commitment);
      final id = await localDataSource.addCommitment(commitmentModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCommitment(
    FinancialCommitment commitment,
  ) async {
    try {
      final commitmentModel = FinancialCommitmentModel.fromEntity(commitment);
      final success = await localDataSource.updateCommitment(commitmentModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCommitment(Id id) async {
    try {
      final success = await localDataSource.deleteCommitment(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommitmentContribution>>>
      getContributionsByCommitment(Id commitmentId) async {
    try {
      final contributionModels =
          await localDataSource.getContributionsByCommitment(commitmentId);
      final contributions =
          contributionModels.map((model) => model.toEntity()).toList();
      return Right(contributions);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addContribution(
    CommitmentContribution contribution,
  ) async {
    try {
      final contributionModel =
          CommitmentContributionModel.fromEntity(contribution);
      final id = await localDataSource.addContribution(contributionModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateContribution(
    CommitmentContribution contribution,
  ) async {
    try {
      final contributionModel =
          CommitmentContributionModel.fromEntity(contribution);
      final success =
          await localDataSource.updateContribution(contributionModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteContribution(Id id) async {
    try {
      final success = await localDataSource.deleteContribution(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
