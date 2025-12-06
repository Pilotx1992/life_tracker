import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';

class UpdateAccount implements UseCase<bool, Account> {
  final AccountRepository repository;

  UpdateAccount(this.repository);

  @override
  Future<Either<Failure, bool>> call(Account params) async {
    return await repository.updateAccount(params);
  }
}
