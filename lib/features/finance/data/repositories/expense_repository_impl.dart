import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/expense_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/expense_model.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenseModels = await localDataSource.getAllExpenses();
      final expenses = expenseModels.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getExpenseById(Id id) async {
    try {
      final expenseModel = await localDataSource.getExpenseById(id);
      return Right(expenseModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenseModels =
          await localDataSource.getExpensesByDateRange(startDate, endDate);
      final expenses = expenseModels.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
    Id categoryId,
  ) async {
    try {
      final expenseModels =
          await localDataSource.getExpensesByCategory(categoryId);
      final expenses = expenseModels.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByAccount(
    Id accountId,
  ) async {
    try {
      final expenseModels =
          await localDataSource.getExpensesByAccount(accountId);
      final expenses = expenseModels.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final id = await localDataSource.addExpense(expenseModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final success = await localDataSource.updateExpense(expenseModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteExpense(Id id) async {
    try {
      final success = await localDataSource.deleteExpense(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> calculateTotalExpenses(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final total =
          await localDataSource.calculateTotalExpenses(startDate, endDate);
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
