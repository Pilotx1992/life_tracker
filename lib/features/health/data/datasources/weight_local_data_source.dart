import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/health/data/models/weight_model.dart';

abstract class WeightLocalDataSource {
  Future<List<WeightModel>> getAllWeights();
  Future<WeightModel?> getWeightById(Id id);
  Future<List<WeightModel>> getWeightsByDateRange(DateTime startDate, DateTime endDate);
  Future<WeightModel?> getLatestWeight();
  Future<Id> addWeight(WeightModel weight);
  Future<bool> updateWeight(WeightModel weight);
  Future<bool> deleteWeight(Id id);
}

class WeightLocalDataSourceImpl implements WeightLocalDataSource {
  final DatabaseService? databaseService;
  final Isar? isarInstance;

  /// Accept either a [DatabaseService] (to lazily access Isar) or an
  /// already-open [Isar] instance. This keeps callers flexible: some
  /// providers pass the DatabaseService singleton, others pass the
  /// initialized Isar from an async provider.
  WeightLocalDataSourceImpl({this.databaseService, this.isarInstance})
  : assert(
      databaseService != null || isarInstance != null,
      'Either databaseService or isarInstance must be provided',
    );

  @override
  Future<List<WeightModel>> getAllWeights() async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.weightModels.where().findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<WeightModel?> getWeightById(Id id) async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.weightModels.get(id);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<WeightModel>> getWeightsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.weightModels
          .filter()
          .dateBetween(startDate, endDate)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<WeightModel?> getLatestWeight() async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.weightModels.where().sortByDateDesc().limit(1).build().findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<Id> addWeight(WeightModel weight) async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.writeTxn(() => isar.weightModels.put(weight));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> updateWeight(WeightModel weight) async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.writeTxn(() async {
        final existingWeight = await isar.weightModels.get(weight.id);
        if (existingWeight == null) {
          return false;
        }
        await isar.weightModels.put(weight);
        return true;
      });
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> deleteWeight(Id id) async {
    try {
      final isar = isarInstance ?? await databaseService!.database;
      return await isar.writeTxn(() => isar.weightModels.delete(id));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}