import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class UpdateDebt implements UseCase<bool, Debt> {
  final DebtRepository repository;

  UpdateDebt(this.repository);

  @override
  Future<Either<Failure, bool>> call(Debt params) async {
    return await repository.updateDebt(params);
  }
}
