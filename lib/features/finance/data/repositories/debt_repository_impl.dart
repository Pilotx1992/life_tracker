import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/debt_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/debt_model.dart';
import 'package:life_tracker/features/finance/data/models/debt_payment_model.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource localDataSource;

  DebtRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Debt>>> getAllDebts() async {
    try {
      final debtModels = await localDataSource.getAllDebts();
      final debts = debtModels.map((model) => model.toEntity()).toList();
      return Right(debts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Debt>>> getDebtsByType(String type) async {
    try {
      final debtModels = await localDataSource.getDebtsByType(type);
      final debts = debtModels.map((model) => model.toEntity()).toList();
      return Right(debts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Debt?>> getDebtById(Id id) async {
    try {
      final debtModel = await localDataSource.getDebtById(id);
      return Right(debtModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Debt>>> getOverdueDebts() async {
    try {
      final debtModels = await localDataSource.getOverdueDebts();
      final debts = debtModels.map((model) => model.toEntity()).toList();
      return Right(debts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addDebt(Debt debt) async {
    try {
      final debtModel = DebtModel.fromEntity(debt);
      final id = await localDataSource.addDebt(debtModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateDebt(Debt debt) async {
    try {
      final debtModel = DebtModel.fromEntity(debt);
      final success = await localDataSource.updateDebt(debtModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDebt(Id id) async {
    try {
      final success = await localDataSource.deleteDebt(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> calculateTotalDebts(String type) async {
    try {
      final total = await localDataSource.calculateTotalDebts(type);
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> calculateNetPosition() async {
    try {
      final net = await localDataSource.calculateNetPosition();
      return Right(net);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DebtPayment>>> getPaymentsByDebt(
    Id debtId,
  ) async {
    try {
      final paymentModels = await localDataSource.getPaymentsByDebt(debtId);
      final payments = paymentModels.map((model) => model.toEntity()).toList();
      return Right(payments);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addPayment(DebtPayment payment) async {
    try {
      final paymentModel = DebtPaymentModel.fromEntity(payment);
      final id = await localDataSource.addPayment(paymentModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
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
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
