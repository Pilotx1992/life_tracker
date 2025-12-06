import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';

class AddIncome implements UseCase<Id, Income> {
  final IncomeRepository repository;

  AddIncome(this.repository);

  @override
  Future<Either<Failure, Id>> call(Income params) async {
    return await repository.addIncome(params);
  }
}
