import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';

class DeleteIncomeParams extends Equatable {
  final Id id;

  const DeleteIncomeParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteIncome implements UseCase<bool, DeleteIncomeParams> {
  final IncomeRepository repository;

  DeleteIncome(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteIncomeParams params) async {
    return await repository.deleteIncome(params.id);
  }
}
