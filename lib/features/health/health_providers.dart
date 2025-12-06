import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/features/health/data/datasources/weight_local_data_source.dart';
import 'package:life_tracker/features/health/data/repositories/weight_repository_impl.dart';
import 'package:life_tracker/features/health/domain/repositories/weight_repository.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_ideal_weight.dart';
import 'package:life_tracker/features/health/data/datasources/medication_local_data_source.dart';
import 'package:life_tracker/features/health/data/repositories/medication_repository_impl.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService.instance);

final weightLocalDataSourceProvider = Provider<WeightLocalDataSource>(
  (ref) => WeightLocalDataSourceImpl(databaseService: ref.read(databaseServiceProvider)),
);

final weightRepositoryProvider = Provider<WeightRepository>(
  (ref) => WeightRepositoryImpl(ref.read(weightLocalDataSourceProvider)),
);

final calculateIdealWeightUseCaseProvider = Provider<CalculateIdealWeight>((ref) => CalculateIdealWeight());

final medicationLocalDataSourceProvider = Provider<MedicationLocalDataSource>(
  (ref) => MedicationLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final medicationRepositoryProvider = Provider<MedicationRepository>(
  (ref) => MedicationRepositoryImpl(ref.read(medicationLocalDataSourceProvider)),
);
