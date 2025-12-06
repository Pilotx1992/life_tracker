import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/income_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/income_model.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeLocalDataSource localDataSource;

  IncomeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Income>>> getAllIncomes() async {
    try {
      final incomeModels = await localDataSource.getAllIncomes();
      final incomes = incomeModels.map((model) => model.toEntity()).toList();
      return Right(incomes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Income?>> getIncomeById(Id id) async {
    try {
      final incomeModel = await localDataSource.getIncomeById(id);
      return Right(incomeModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Income>>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final incomeModels =
          await localDataSource.getIncomesByDateRange(startDate, endDate);
      final incomes = incomeModels.map((model) => model.toEntity()).toList();
      return Right(incomes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Income>>> getIncomesByAccount(
    Id accountId,
  ) async {
    try {
      final incomeModels = await localDataSource.getIncomesByAccount(accountId);
      final incomes = incomeModels.map((model) => model.toEntity()).toList();
      return Right(incomes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Income>>> getIncomesBySource(
    String source,
  ) async {
    try {
      final incomeModels = await localDataSource.getIncomesBySource(source);
      final incomes = incomeModels.map((model) => model.toEntity()).toList();
      return Right(incomes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addIncome(Income income) async {
    try {
      final incomeModel = IncomeModel.fromEntity(income);
      final id = await localDataSource.addIncome(incomeModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateIncome(Income income) async {
    try {
      final incomeModel = IncomeModel.fromEntity(income);
      final success = await localDataSource.updateIncome(incomeModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteIncome(Id id) async {
    try {
      final success = await localDataSource.deleteIncome(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> calculateTotalIncome(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final total =
          await localDataSource.calculateTotalIncome(startDate, endDate);
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
