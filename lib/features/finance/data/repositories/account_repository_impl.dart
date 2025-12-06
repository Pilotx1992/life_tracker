import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/account_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/account_model.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;

  AccountRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    try {
      final accountModels = await localDataSource.getAllAccounts();
      final accounts = accountModels.map((model) => model.toEntity()).toList();
      return Right(accounts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Account?>> getAccountById(Id id) async {
    try {
      final accountModel = await localDataSource.getAccountById(id);
      return Right(accountModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      final id = await localDataSource.addAccount(accountModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      final success = await localDataSource.updateAccount(accountModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount(Id id) async {
    try {
      final success = await localDataSource.deleteAccount(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> calculateTotalBalance() async {
    try {
      final total = await localDataSource.calculateTotalBalance();
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
