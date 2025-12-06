import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';

class CalculateTotalIncomeParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const CalculateTotalIncomeParams({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class CalculateTotalIncome
    implements UseCase<double, CalculateTotalIncomeParams> {
  final IncomeRepository repository;

  CalculateTotalIncome(this.repository);

  @override
  Future<Either<Failure, double>> call(
    CalculateTotalIncomeParams params,
  ) async {
    return await repository.calculateTotalIncome(
      params.startDate,
      params.endDate,
    );
  }
}
