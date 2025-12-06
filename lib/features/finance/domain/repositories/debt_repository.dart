import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';

abstract class DebtRepository {
  Future<Either<Failure, List<Debt>>> getAllDebts();
  Future<Either<Failure, List<Debt>>> getDebtsByType(
    String type,
  ); // 'i_owe' or 'owed_to_me'
  Future<Either<Failure, Debt?>> getDebtById(Id id);
  Future<Either<Failure, List<Debt>>> getOverdueDebts();
  Future<Either<Failure, Id>> addDebt(Debt debt);
  Future<Either<Failure, bool>> updateDebt(Debt debt);
  Future<Either<Failure, bool>> deleteDebt(Id id);
  Future<Either<Failure, double>> calculateTotalDebts(String type);
  Future<Either<Failure, double>> calculateNetPosition();

  // Debt Payment methods
  Future<Either<Failure, List<DebtPayment>>> getPaymentsByDebt(Id debtId);
  Future<Either<Failure, Id>> addPayment(DebtPayment payment);
  Future<Either<Failure, bool>> deletePayment(Id id);
}
