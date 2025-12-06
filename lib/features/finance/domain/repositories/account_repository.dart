import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<Account>>> getAllAccounts();
  Future<Either<Failure, Account?>> getAccountById(Id id);
  Future<Either<Failure, Id>> addAccount(Account account);
  Future<Either<Failure, bool>> updateAccount(Account account);
  Future<Either<Failure, bool>> deleteAccount(Id id);
  Future<Either<Failure, double>> calculateTotalBalance();
}
