import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class GetExpensesByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetExpensesByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class GetExpensesByDateRange
    implements UseCase<List<Expense>, GetExpensesByDateRangeParams> {
  final ExpenseRepository repository;

  GetExpensesByDateRange(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(
    GetExpensesByDateRangeParams params,
  ) async {
    return await repository.getExpensesByDateRange(
      params.startDate,
      params.endDate,
    );
  }
}
