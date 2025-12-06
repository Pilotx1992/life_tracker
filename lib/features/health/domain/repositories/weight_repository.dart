import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';

abstract class WeightRepository {
  Future<Either<Failure, List<WeightEntry>>> getAllWeights();
  Future<Either<Failure, WeightEntry>> getWeightById(Id id);
  Future<Either<Failure, List<WeightEntry>>> getWeightsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, WeightEntry>> getLatestWeight();
  Future<Either<Failure, Id>> addWeight(WeightEntry weight);
  Future<Either<Failure, bool>> updateWeight(WeightEntry weight);
  Future<Either<Failure, bool>> deleteWeight(Id id);
}
