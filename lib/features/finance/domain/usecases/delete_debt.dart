import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class DeleteDebtParams extends Equatable {
  final Id id;

  const DeleteDebtParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteDebt implements UseCase<bool, DeleteDebtParams> {
  final DebtRepository repository;

  DeleteDebt(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteDebtParams params) async {
    return await repository.deleteDebt(params.id);
  }
}
