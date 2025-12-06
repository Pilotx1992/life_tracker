import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/recurring_bill_model.dart';
import 'package:life_tracker/features/finance/data/models/bill_payment_model.dart';

abstract class BillLocalDataSource {
  Future<List<RecurringBillModel>> getAllBills();
  Future<List<RecurringBillModel>> getActiveBills();
  Future<List<RecurringBillModel>> getUpcomingBills(DateTime endDate);
  Future<List<RecurringBillModel>> getOverdueBills();
  Future<RecurringBillModel?> getBillById(Id id);
  Future<Id> addBill(RecurringBillModel bill);
  Future<bool> updateBill(RecurringBillModel bill);
  Future<bool> deleteBill(Id id);

  // Bill Payment methods
  Future<List<BillPaymentModel>> getPaymentsByBill(Id billId);
  Future<Id> addPayment(BillPaymentModel payment);
  Future<bool> deletePayment(Id id);
}

class BillLocalDataSourceImpl implements BillLocalDataSource {
  final DatabaseService _databaseService;

  BillLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<RecurringBillModel>> getAllBills() async {
    try {
      final isar = await _databaseService.database;
      final bills = await isar.recurringBillModels.where().findAll();
      bills.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      return bills;
    } catch (e) {
      throw CacheException('Failed to get bills: $e');
    }
  }

  @override
  Future<List<RecurringBillModel>> getActiveBills() async {
    try {
      final isar = await _databaseService.database;
      final bills = await isar.recurringBillModels
          .filter()
          .isActiveEqualTo(true)
          .findAll();
      bills.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      return bills;
    } catch (e) {
      throw CacheException('Failed to get active bills: $e');
    }
  }

  @override
  Future<List<RecurringBillModel>> getUpcomingBills(DateTime endDate) async {
    try {
      final isar = await _databaseService.database;
      final now = DateTime.now();
      final bills = await isar.recurringBillModels
          .filter()
          .isActiveEqualTo(true)
          .nextDueDateGreaterThan(now.subtract(const Duration(days: 1)))
          .nextDueDateLessThan(endDate.add(const Duration(days: 1)))
          .findAll();
      bills.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      return bills;
    } catch (e) {
      throw CacheException('Failed to get upcoming bills: $e');
    }
  }

  @override
  Future<List<RecurringBillModel>> getOverdueBills() async {
    try {
      final isar = await _databaseService.database;
      final now = DateTime.now();
      final bills = await isar.recurringBillModels
          .filter()
          .isActiveEqualTo(true)
          .nextDueDateLessThan(now)
          .findAll();
      bills.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      return bills;
    } catch (e) {
      throw CacheException('Failed to get overdue bills: $e');
    }
  }

  @override
  Future<RecurringBillModel?> getBillById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.recurringBillModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get bill: $e');
    }
  }

  @override
  Future<Id> addBill(RecurringBillModel bill) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.recurringBillModels.put(bill);
      });
      return bill.id;
    } catch (e) {
      throw CacheException('Failed to add bill: $e');
    }
  }

  @override
  Future<bool> updateBill(RecurringBillModel bill) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.recurringBillModels.put(bill);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update bill: $e');
    }
  }

  @override
  Future<bool> deleteBill(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        // Delete associated payments first
        final payments =
            await isar.billPaymentModels.filter().billIdEqualTo(id).findAll();
        await isar.billPaymentModels
            .deleteAll(payments.map((p) => p.id).toList());

        // Delete the bill
        await isar.recurringBillModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete bill: $e');
    }
  }

  @override
  Future<List<BillPaymentModel>> getPaymentsByBill(Id billId) async {
    try {
      final isar = await _databaseService.database;
      final payments =
          await isar.billPaymentModels.filter().billIdEqualTo(billId).findAll();
      payments.sort(
        (a, b) => b.paidDate.compareTo(a.paidDate),
      ); // Most recent first
      return payments;
    } catch (e) {
      throw CacheException('Failed to get payments by bill: $e');
    }
  }

  @override
  Future<Id> addPayment(BillPaymentModel payment) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.billPaymentModels.put(payment);
      });
      return payment.id;
    } catch (e) {
      throw CacheException('Failed to add payment: $e');
    }
  }

  @override
  Future<bool> deletePayment(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.billPaymentModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete payment: $e');
    }
  }
}
