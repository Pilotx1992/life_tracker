import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class CalculateTotalDebtsParams extends Equatable {
  final String type; // 'i_owe' or 'owed_to_me'

  const CalculateTotalDebtsParams({required this.type});

  @override
  List<Object?> get props => [type];
}

class CalculateTotalDebts
    implements UseCase<double, CalculateTotalDebtsParams> {
  final DebtRepository repository;

  CalculateTotalDebts(this.repository);

  @override
  Future<Either<Failure, double>> call(CalculateTotalDebtsParams params) async {
    return await repository.calculateTotalDebts(params.type);
  }
}
