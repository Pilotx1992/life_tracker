import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';

class DeleteExpenseParams extends Equatable {
  final Id id;

  const DeleteExpenseParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteExpense implements UseCase<bool, DeleteExpenseParams> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteExpenseParams params) async {
    return await repository.deleteExpense(params.id);
  }
}
