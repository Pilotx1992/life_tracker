import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';

class GetAccounts implements UseCase<List<Account>, NoParams> {
  final AccountRepository repository;

  GetAccounts(this.repository);

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) async {
    return await repository.getAllAccounts();
  }
}
