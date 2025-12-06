import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class AddDebt implements UseCase<Id, Debt> {
  final DebtRepository repository;

  AddDebt(this.repository);

  @override
  Future<Either<Failure, Id>> call(Debt params) async {
    return await repository.addDebt(params);
  }
}
