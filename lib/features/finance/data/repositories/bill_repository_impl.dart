import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/bill_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/recurring_bill_model.dart';
import 'package:life_tracker/features/finance/data/models/bill_payment_model.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/entities/bill_payment.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class BillRepositoryImpl implements BillRepository {
  final BillLocalDataSource localDataSource;

  BillRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<RecurringBill>>> getAllBills() async {
    try {
      final billModels = await localDataSource.getAllBills();
      final bills = billModels.map((model) => model.toEntity()).toList();
      return Right(bills);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringBill>>> getActiveBills() async {
    try {
      final billModels = await localDataSource.getActiveBills();
      final bills = billModels.map((model) => model.toEntity()).toList();
      return Right(bills);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringBill>>> getUpcomingBills(
    DateTime endDate,
  ) async {
    try {
      final billModels = await localDataSource.getUpcomingBills(endDate);
      final bills = billModels.map((model) => model.toEntity()).toList();
      return Right(bills);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringBill>>> getOverdueBills() async {
    try {
      final billModels = await localDataSource.getOverdueBills();
      final bills = billModels.map((model) => model.toEntity()).toList();
      return Right(bills);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, RecurringBill?>> getBillById(Id id) async {
    try {
      final billModel = await localDataSource.getBillById(id);
      return Right(billModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addBill(RecurringBill bill) async {
    try {
      final billModel = RecurringBillModel.fromEntity(bill);
      final id = await localDataSource.addBill(billModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBill(RecurringBill bill) async {
    try {
      final billModel = RecurringBillModel.fromEntity(bill);
      final success = await localDataSource.updateBill(billModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBill(Id id) async {
    try {
      final success = await localDataSource.deleteBill(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BillPayment>>> getPaymentsByBill(
    Id billId,
  ) async {
    try {
      final paymentModels = await localDataSource.getPaymentsByBill(billId);
      final payments = paymentModels.map((model) => model.toEntity()).toList();
      return Right(payments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addPayment(BillPayment payment) async {
    try {
      final paymentModel = BillPaymentModel.fromEntity(payment);
      final id = await localDataSource.addPayment(paymentModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePayment(Id id) async {
    try {
      final success = await localDataSource.deletePayment(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  // ✨ Installment-specific methods

  @override
  Future<Either<Failure, List<RecurringBill>>> getInstallments() async {
    try {
      final billModels = await localDataSource.getAllBills();
      final installments = billModels
          .where((model) => model.type == BillType.installment)
          .map((model) => model.toEntity())
          .toList();
      return Right(installments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringBill>>> getActiveInstallments() async {
    try {
      final billModels = await localDataSource.getAllBills();
      final activeInstallments = billModels
          .where((model) =>
              model.type == BillType.installment &&
              model.isActive &&
              model.paidAmount < model.totalAmount,)
          .map((model) => model.toEntity())
          .toList();
      return Right(activeInstallments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalRemainingInstallments() async {
    try {
      final billModels = await localDataSource.getAllBills();
      final totalRemaining = billModels
          .where((model) =>
              model.type == BillType.installment &&
              model.isActive &&
              model.paidAmount < model.totalAmount,)
          .fold<double>(0.0,
              (sum, model) => sum + (model.totalAmount - model.paidAmount),);
      return Right(totalRemaining);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> makeInstallmentPayment({
    required Id billId,
    required double amount,
    required DateTime paidDate,
    String? note,
    Id? expenseId,
  }) async {
    try {
      // Get the bill
      final billModel = await localDataSource.getBillById(billId);
      if (billModel == null) {
        return const Left(CacheFailure('Bill not found'));
      }

      // Create payment record
      final paymentModel = BillPaymentModel()
        ..billId = billId
        ..paidDate = paidDate
        ..amount = amount
        ..note = note
        ..expenseId = expenseId;

      await localDataSource.addPayment(paymentModel);

      // Update the bill's paid amount and installment count
      final updatedBill = billModel.copyWith(
        paidAmount: billModel.paidAmount + amount,
        paidInstallments: billModel.paidInstallments + 1,
      );

      // If fully paid, mark as inactive
      if (updatedBill.paidAmount >= updatedBill.totalAmount) {
        updatedBill.isActive = false;
      }

      await localDataSource.updateBill(updatedBill);

      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
