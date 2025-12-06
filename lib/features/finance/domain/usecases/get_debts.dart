import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class GetDebtsParams extends Equatable {
  final String? type; // 'i_owe' or 'owed_to_me' or null for all

  const GetDebtsParams({this.type});

  @override
  List<Object?> get props => [type];
}

class GetDebts implements UseCase<List<Debt>, GetDebtsParams> {
  final DebtRepository repository;

  GetDebts(this.repository);

  @override
  Future<Either<Failure, List<Debt>>> call(GetDebtsParams params) async {
    if (params.type != null) {
      return await repository.getDebtsByType(params.type!);
    }
    return await repository.getAllDebts();
  }
}
