import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class UpdateExpense implements UseCase<bool, Expense> {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  @override
  Future<Either<Failure, bool>> call(Expense params) async {
    return await repository.updateExpense(params);
  }
}
