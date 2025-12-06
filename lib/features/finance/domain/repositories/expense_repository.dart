import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, Expense?>> getExpenseById(Id id);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(Id categoryId);
  Future<Either<Failure, List<Expense>>> getExpensesByAccount(Id accountId);
  Future<Either<Failure, Id>> addExpense(Expense expense);
  Future<Either<Failure, bool>> updateExpense(Expense expense);
  Future<Either<Failure, bool>> deleteExpense(Id id);
  Future<Either<Failure, double>> calculateTotalExpenses(
    DateTime? startDate,
    DateTime? endDate,
  );
}
