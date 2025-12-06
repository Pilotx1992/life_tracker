import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class AddCommitment implements UseCase<Id, FinancialCommitment> {
  final CommitmentRepository repository;

  AddCommitment(this.repository);

  @override
  Future<Either<Failure, Id>> call(FinancialCommitment params) async {
    return await repository.addCommitment(params);
  }
}
