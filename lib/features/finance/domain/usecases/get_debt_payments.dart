import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class GetDebtPaymentsParams extends Equatable {
  final Id debtId;

  const GetDebtPaymentsParams({required this.debtId});

  @override
  List<Object?> get props => [debtId];
}

class GetDebtPayments
    implements UseCase<List<DebtPayment>, GetDebtPaymentsParams> {
  final DebtRepository repository;

  GetDebtPayments(this.repository);

  @override
  Future<Either<Failure, List<DebtPayment>>> call(
    GetDebtPaymentsParams params,
  ) async {
    return await repository.getPaymentsByDebt(params.debtId);
  }
}
