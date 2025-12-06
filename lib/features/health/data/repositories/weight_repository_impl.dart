import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/data/datasources/weight_local_data_source.dart';
import 'package:life_tracker/features/health/data/models/weight_model.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightLocalDataSource localDataSource;

  WeightRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<WeightEntry>>> getAllWeights() async {
    try {
      final weightModels = await localDataSource.getAllWeights();
      return Right(weightModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WeightEntry>> getWeightById(Id id) async {
    try {
      final weightModel = await localDataSource.getWeightById(id);
      if (weightModel != null) {
        return Right(weightModel.toEntity());
      } else {
        return const Left(CacheFailure('Weight entry not found'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<WeightEntry>>> getWeightsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final weightModels = await localDataSource.getWeightsByDateRange(startDate, endDate);
      return Right(weightModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WeightEntry>> getLatestWeight() async {
    try {
      final weightModel = await localDataSource.getLatestWeight();
      if (weightModel != null) {
        return Right(weightModel.toEntity());
      } else {
        return const Left(CacheFailure('No latest weight entry found'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Id>> addWeight(WeightEntry weight) async {
    try {
      final id = await localDataSource.addWeight(WeightModel.fromEntity(weight));
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateWeight(WeightEntry weight) async {
    try {
      final success = await localDataSource.updateWeight(WeightModel.fromEntity(weight));
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteWeight(Id id) async {
    try {
      final success = await localDataSource.deleteWeight(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}