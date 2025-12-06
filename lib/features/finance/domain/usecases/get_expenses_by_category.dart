import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class GetExpensesByCategoryParams extends Equatable {
  final Id categoryId;

  const GetExpensesByCategoryParams({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class GetExpensesByCategory
    implements UseCase<List<Expense>, GetExpensesByCategoryParams> {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(
    GetExpensesByCategoryParams params,
  ) async {
    return await repository.getExpensesByCategory(params.categoryId);
  }
}
