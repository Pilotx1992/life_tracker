import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class GetCommitmentById implements UseCase<FinancialCommitment?, Id> {
  final CommitmentRepository repository;

  GetCommitmentById(this.repository);

  @override
  Future<Either<Failure, FinancialCommitment?>> call(Id params) async {
    return await repository.getCommitmentById(params);
  }
}
