import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/debt_model.dart';
import 'package:life_tracker/features/finance/data/models/debt_payment_model.dart';

abstract class DebtLocalDataSource {
  Future<List<DebtModel>> getAllDebts();
  Future<List<DebtModel>> getDebtsByType(
    String type,
  ); // 'i_owe' or 'owed_to_me'
  Future<DebtModel?> getDebtById(Id id);
  Future<List<DebtModel>> getOverdueDebts();
  Future<Id> addDebt(DebtModel debt);
  Future<bool> updateDebt(DebtModel debt);
  Future<bool> deleteDebt(Id id);
  Future<double> calculateTotalDebts(String type);
  Future<double> calculateNetPosition(); // Total owed to me - Total I owe

  // Debt Payment methods
  Future<List<DebtPaymentModel>> getPaymentsByDebt(Id debtId);
  Future<Id> addPayment(DebtPaymentModel payment);
  Future<bool> deletePayment(Id id);
}

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  final DatabaseService _databaseService;

  DebtLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<DebtModel>> getAllDebts() async {
    try {
      final isar = await _databaseService.database;
      final debts = await isar.debtModels.where().findAll();
      debts.sort((a, b) => a.dueDate.compareTo(b.dueDate)); // Sort by due date
      return debts;
    } catch (e) {
      throw CacheException('Failed to get debts: $e');
    }
  }

  @override
  Future<List<DebtModel>> getDebtsByType(String type) async {
    try {
      final isar = await _databaseService.database;
      final debts = await isar.debtModels.filter().typeEqualTo(type).findAll();
      debts.sort((a, b) => a.dueDate.compareTo(b.dueDate)); // Sort by due date
      return debts;
    } catch (e) {
      throw CacheException('Failed to get debts by type: $e');
    }
  }

  @override
  Future<DebtModel?> getDebtById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.debtModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get debt: $e');
    }
  }

  @override
  Future<List<DebtModel>> getOverdueDebts() async {
    try {
      final isar = await _databaseService.database;
      final now = DateTime.now();
      final debts = await isar.debtModels
          .filter()
          .dueDateLessThan(now)
          .isPaidEqualTo(false)
          .findAll();
      debts.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return debts;
    } catch (e) {
      throw CacheException('Failed to get overdue debts: $e');
    }
  }

  @override
  Future<Id> addDebt(DebtModel debt) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        debt.createdAt ??= DateTime.now();
        return await isar.debtModels.put(debt);
      });
    } catch (e) {
      throw CacheException('Failed to add debt: $e');
    }
  }

  @override
  Future<bool> updateDebt(DebtModel debt) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.debtModels.put(debt);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update debt: $e');
    }
  }

  @override
  Future<bool> deleteDebt(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        // Also delete all payments for this debt
        final payments =
            await isar.debtPaymentModels.filter().debtIdEqualTo(id).findAll();
        for (final payment in payments) {
          await isar.debtPaymentModels.delete(payment.id);
        }
        await isar.debtModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete debt: $e');
    }
  }

  @override
  Future<double> calculateTotalDebts(String type) async {
    try {
      final debts = await getDebtsByType(type);
      return debts.fold<double>(0.0, (sum, debt) {
        final remaining = debt.amount - debt.paidAmount;
        return sum + (debt.isPaid ? 0.0 : remaining);
      });
    } catch (e) {
      throw CacheException('Failed to calculate total debts: $e');
    }
  }

  @override
  Future<double> calculateNetPosition() async {
    try {
      final iOwe = await calculateTotalDebts('i_owe');
      final owedToMe = await calculateTotalDebts('owed_to_me');
      return owedToMe - iOwe;
    } catch (e) {
      throw CacheException('Failed to calculate net position: $e');
    }
  }

  @override
  Future<List<DebtPaymentModel>> getPaymentsByDebt(Id debtId) async {
    try {
      final isar = await _databaseService.database;
      final payments =
          await isar.debtPaymentModels.filter().debtIdEqualTo(debtId).findAll();
      payments.sort(
        (a, b) => b.paymentDate.compareTo(a.paymentDate),
      ); // Sort descending
      return payments;
    } catch (e) {
      throw CacheException('Failed to get payments: $e');
    }
  }

  @override
  Future<Id> addPayment(DebtPaymentModel payment) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        final paymentId = await isar.debtPaymentModels.put(payment);

        // Update debt's paid amount
        final debt = await isar.debtModels.get(payment.debtId);
        if (debt != null) {
          debt.paidAmount = (debt.paidAmount + payment.amount);
          if (debt.paidAmount >= debt.amount) {
            debt.isPaid = true;
            debt.paidAmount = debt.amount; // Cap at total amount
          }
          await isar.debtModels.put(debt);
        }

        return paymentId;
      });
    } catch (e) {
      throw CacheException('Failed to add payment: $e');
    }
  }

  @override
  Future<bool> deletePayment(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        final payment = await isar.debtPaymentModels.get(id);
        if (payment != null) {
          // Update debt's paid amount
          final debt = await isar.debtModels.get(payment.debtId);
          if (debt != null) {
            debt.paidAmount =
                (debt.paidAmount - payment.amount).clamp(0.0, debt.amount);
            if (debt.paidAmount < debt.amount) {
              debt.isPaid = false;
            }
            await isar.debtModels.put(debt);
          }
          await isar.debtPaymentModels.delete(id);
          return true;
        }
        return false;
      });
    } catch (e) {
      throw CacheException('Failed to delete payment: $e');
    }
  }
}
