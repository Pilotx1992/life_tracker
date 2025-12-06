import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';

abstract class IncomeRepository {
  Future<Either<Failure, List<Income>>> getAllIncomes();
  Future<Either<Failure, Income?>> getIncomeById(Id id);
  Future<Either<Failure, List<Income>>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, List<Income>>> getIncomesByAccount(Id accountId);
  Future<Either<Failure, List<Income>>> getIncomesBySource(String source);
  Future<Either<Failure, Id>> addIncome(Income income);
  Future<Either<Failure, bool>> updateIncome(Income income);
  Future<Either<Failure, bool>> deleteIncome(Id id);
  Future<Either<Failure, double>> calculateTotalIncome(
    DateTime? startDate,
    DateTime? endDate,
  );
}
