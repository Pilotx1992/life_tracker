import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';

class AddAccount implements UseCase<Id, Account> {
  final AccountRepository repository;

  AddAccount(this.repository);

  @override
  Future<Either<Failure, Id>> call(Account params) async {
    return await repository.addAccount(params);
  }
}
