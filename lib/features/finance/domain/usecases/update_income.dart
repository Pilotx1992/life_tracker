import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';

class UpdateIncome implements UseCase<bool, Income> {
  final IncomeRepository repository;

  UpdateIncome(this.repository);

  @override
  Future<Either<Failure, bool>> call(Income params) async {
    return await repository.updateIncome(params);
  }
}
