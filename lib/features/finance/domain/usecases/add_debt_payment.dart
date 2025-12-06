import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class AddDebtPayment implements UseCase<Id, DebtPayment> {
  final DebtRepository repository;

  AddDebtPayment(this.repository);

  @override
  Future<Either<Failure, Id>> call(DebtPayment params) async {
    return await repository.addPayment(params);
  }
}
