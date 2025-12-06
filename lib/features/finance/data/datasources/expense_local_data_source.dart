import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(Id id);
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<ExpenseModel>> getExpensesByCategory(Id categoryId);
  Future<List<ExpenseModel>> getExpensesByAccount(Id accountId);
  Future<Id> addExpense(ExpenseModel expense);
  Future<bool> updateExpense(ExpenseModel expense);
  Future<bool> deleteExpense(Id id);
  Future<double> calculateTotalExpenses(DateTime? startDate, DateTime? endDate);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final DatabaseService _databaseService;

  ExpenseLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final isar = await _databaseService.database;
      final expenses = await isar.expenseModels.where().findAll();
      expenses
          .sort((a, b) => b.date.compareTo(a.date)); // Sort descending by date
      return expenses;
    } catch (e) {
      throw CacheException('Failed to get expenses: $e');
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.expenseModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get expense: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final isar = await _databaseService.database;
      final expenses = await isar.expenseModels
          .filter()
          .dateBetween(startDate, endDate)
          .findAll();
      expenses
          .sort((a, b) => b.date.compareTo(a.date)); // Sort descending by date
      return expenses;
    } catch (e) {
      throw CacheException('Failed to get expenses by date range: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(Id categoryId) async {
    try {
      final isar = await _databaseService.database;
      final expenses = await isar.expenseModels
          .filter()
          .categoryIdEqualTo(categoryId)
          .findAll();
      expenses
          .sort((a, b) => b.date.compareTo(a.date)); // Sort descending by date
      return expenses;
    } catch (e) {
      throw CacheException('Failed to get expenses by category: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByAccount(Id accountId) async {
    try {
      final isar = await _databaseService.database;
      final expenses = await isar.expenseModels
          .filter()
          .accountIdEqualTo(accountId)
          .findAll();
      expenses
          .sort((a, b) => b.date.compareTo(a.date)); // Sort descending by date
      return expenses;
    } catch (e) {
      throw CacheException('Failed to get expenses by account: $e');
    }
  }

  @override
  Future<Id> addExpense(ExpenseModel expense) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.expenseModels.put(expense);
      });
    } catch (e) {
      throw CacheException('Failed to add expense: $e');
    }
  }

  @override
  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.expenseModels.put(expense);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update expense: $e');
    }
  }

  @override
  Future<bool> deleteExpense(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.expenseModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete expense: $e');
    }
  }

  @override
  Future<double> calculateTotalExpenses(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final isar = await _databaseService.database;
      List<ExpenseModel> expenses;

      if (startDate != null && endDate != null) {
        expenses = await isar.expenseModels
            .filter()
            .dateBetween(startDate, endDate)
            .findAll();
      } else {
        expenses = await isar.expenseModels.where().findAll();
      }

      return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      throw CacheException('Failed to calculate total expenses: $e');
    }
  }
}
