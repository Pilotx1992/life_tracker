import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';

class CalculateTotalBalance implements UseCase<double, NoParams> {
  final AccountRepository repository;

  CalculateTotalBalance(this.repository);

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return await repository.calculateTotalBalance();
  }
}
