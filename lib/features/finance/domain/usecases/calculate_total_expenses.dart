import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class CalculateTotalExpensesParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const CalculateTotalExpensesParams({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class CalculateTotalExpenses
    implements UseCase<double, CalculateTotalExpensesParams> {
  final ExpenseRepository repository;

  CalculateTotalExpenses(this.repository);

  @override
  Future<Either<Failure, double>> call(
    CalculateTotalExpensesParams params,
  ) async {
    return await repository.calculateTotalExpenses(
      params.startDate,
      params.endDate,
    );
  }
}
