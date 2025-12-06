import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class AddExpense implements UseCase<Id, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, Id>> call(Expense params) async {
    return await repository.addExpense(params);
  }
}
