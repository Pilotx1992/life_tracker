import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/account_model.dart';

abstract class AccountLocalDataSource {
  Future<List<AccountModel>> getAllAccounts();
  Future<AccountModel?> getAccountById(Id id);
  Future<Id> addAccount(AccountModel account);
  Future<bool> updateAccount(AccountModel account);
  Future<bool> deleteAccount(Id id);
  Future<double> calculateTotalBalance();
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final DatabaseService _databaseService;

  AccountLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<AccountModel>> getAllAccounts() async {
    try {
      final isar = await _databaseService.database;
      return await isar.accountModels.where().findAll();
    } catch (e) {
      throw CacheException('Failed to get accounts: $e');
    }
  }

  @override
  Future<AccountModel?> getAccountById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.accountModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get account: $e');
    }
  }

  @override
  Future<Id> addAccount(AccountModel account) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.accountModels.put(account);
      });
    } catch (e) {
      throw CacheException('Failed to add account: $e');
    }
  }

  @override
  Future<bool> updateAccount(AccountModel account) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.accountModels.put(account);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update account: $e');
    }
  }

  @override
  Future<bool> deleteAccount(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.accountModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete account: $e');
    }
  }

  @override
  Future<double> calculateTotalBalance() async {
    try {
      final accounts = await getAllAccounts();
      // حساب Total Balance من الحسابات العادية فقط (بدون Credit Card)
      return accounts
          .where((account) => account.type != 'Credit Card')
          .fold<double>(0.0, (sum, account) => sum + account.balance);
    } catch (e) {
      throw CacheException('Failed to calculate total balance: $e');
    }
  }
}
