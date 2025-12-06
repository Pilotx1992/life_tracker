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
}
