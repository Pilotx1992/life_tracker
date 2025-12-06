import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';

class GetWeights implements UseCase<List<WeightEntry>, GetWeightsParams> {
  final WeightRepository repository;

  GetWeights(this.repository);

  @override
  Future<Either<Failure, List<WeightEntry>>> call(
    GetWeightsParams params,
  ) async {
    if (params.startDate != null && params.endDate != null) {
      return await repository.getWeightsByDateRange(
        params.startDate!,
        params.endDate!,
      );
    } else {
      return await repository.getAllWeights();
    }
  }
}

class GetWeightsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetWeightsParams({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
