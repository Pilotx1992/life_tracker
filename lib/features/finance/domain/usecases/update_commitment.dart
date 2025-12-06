import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';

class UpdateCommitment implements UseCase<bool, FinancialCommitment> {
  final CommitmentRepository repository;

  UpdateCommitment(this.repository);

  @override
  Future<Either<Failure, bool>> call(FinancialCommitment params) async {
    return await repository.updateCommitment(params);
  }
}
