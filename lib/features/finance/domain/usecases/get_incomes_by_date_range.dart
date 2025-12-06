import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';

class GetIncomesByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetIncomesByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class GetIncomesByDateRange
    implements UseCase<List<Income>, GetIncomesByDateRangeParams> {
  final IncomeRepository repository;

  GetIncomesByDateRange(this.repository);

  @override
  Future<Either<Failure, List<Income>>> call(
    GetIncomesByDateRangeParams params,
  ) async {
    return await repository.getIncomesByDateRange(
      params.startDate,
      params.endDate,
    );
  }
}
