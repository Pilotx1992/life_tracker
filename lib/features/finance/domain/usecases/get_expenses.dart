import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class GetExpenses implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) async {
    return await repository.getAllExpenses();
  }
}
