import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/income_model.dart';

abstract class IncomeLocalDataSource {
  Future<List<IncomeModel>> getAllIncomes();
  Future<IncomeModel?> getIncomeById(Id id);
  Future<List<IncomeModel>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<IncomeModel>> getIncomesByAccount(Id accountId);
  Future<List<IncomeModel>> getIncomesBySource(String source);
  Future<Id> addIncome(IncomeModel income);
  Future<bool> updateIncome(IncomeModel income);
  Future<bool> deleteIncome(Id id);
  Future<double> calculateTotalIncome(DateTime? startDate, DateTime? endDate);
}

class IncomeLocalDataSourceImpl implements IncomeLocalDataSource {
  final DatabaseService _databaseService;

  IncomeLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<IncomeModel>> getAllIncomes() async {
    try {
      final isar = await _databaseService.database;
      // Use Isar's built-in sorting for better performance
      return await isar.incomeModels
          .where()
          .sortByDateDesc()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get incomes: $e');
    }
  }

  @override
  Future<IncomeModel?> getIncomeById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.incomeModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get income: $e');
    }
  }

  @override
  Future<List<IncomeModel>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final isar = await _databaseService.database;
      // Use Isar's built-in sorting for better performance
      return await isar.incomeModels
          .filter()
          .dateBetween(startDate, endDate)
          .sortByDateDesc()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get incomes by date range: $e');
    }
  }

  @override
  Future<List<IncomeModel>> getIncomesByAccount(Id accountId) async {
    try {
      final isar = await _databaseService.database;
      // Use Isar's built-in sorting for better performance
      return await isar.incomeModels
          .filter()
          .accountIdEqualTo(accountId)
          .sortByDateDesc()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get incomes by account: $e');
    }
  }

  @override
  Future<List<IncomeModel>> getIncomesBySource(String source) async {
    try {
      final isar = await _databaseService.database;
      // Use Isar's built-in sorting for better performance
      return await isar.incomeModels
          .filter()
          .sourceEqualTo(source)
          .sortByDateDesc()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get incomes by source: $e');
    }
  }

  @override
  Future<Id> addIncome(IncomeModel income) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.incomeModels.put(income);
      });
    } catch (e) {
      throw CacheException('Failed to add income: $e');
    }
  }

  @override
  Future<bool> updateIncome(IncomeModel income) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.incomeModels.put(income);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update income: $e');
    }
  }

  @override
  Future<bool> deleteIncome(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.incomeModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete income: $e');
    }
  }

  @override
  Future<double> calculateTotalIncome(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final isar = await _databaseService.database;
      List<IncomeModel> incomes;

      if (startDate != null && endDate != null) {
        incomes = await isar.incomeModels
            .filter()
            .dateBetween(startDate, endDate)
            .findAll();
      } else {
        incomes = await isar.incomeModels.where().findAll();
      }

      return incomes.fold<double>(0.0, (sum, income) => sum + income.amount);
    } catch (e) {
      throw CacheException('Failed to calculate total income: $e');
    }
  }
}
