import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/entities/bill_payment.dart';

abstract class BillRepository {
  Future<Either<Failure, List<RecurringBill>>> getAllBills();
  Future<Either<Failure, List<RecurringBill>>> getActiveBills();
  Future<Either<Failure, List<RecurringBill>>> getUpcomingBills(
    DateTime endDate,
  );
  Future<Either<Failure, List<RecurringBill>>> getOverdueBills();
  Future<Either<Failure, RecurringBill?>> getBillById(Id id);
  Future<Either<Failure, Id>> addBill(RecurringBill bill);
  Future<Either<Failure, bool>> updateBill(RecurringBill bill);
  Future<Either<Failure, bool>> deleteBill(Id id);

  // Bill Payment methods
  Future<Either<Failure, List<BillPayment>>> getPaymentsByBill(Id billId);
  Future<Either<Failure, Id>> addPayment(BillPayment payment);
  Future<Either<Failure, bool>> deletePayment(Id id);

  // ✨ Installment-specific methods
  /// Get all installment-type bills
  Future<Either<Failure, List<RecurringBill>>> getInstallments();

  /// Get active (not fully paid) installments
  Future<Either<Failure, List<RecurringBill>>> getActiveInstallments();

  /// Get total remaining amount across all installments
  Future<Either<Failure, double>> getTotalRemainingInstallments();

  /// Make a payment for an installment (updates bill and creates payment record)
  Future<Either<Failure, bool>> makeInstallmentPayment({
    required Id billId,
    required double amount,
    required DateTime paidDate,
    String? note,
    Id? expenseId,
  });
}
