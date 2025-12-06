import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/usecases/add_weight.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_bmi.dart';
import 'package:life_tracker/features/health/domain/usecases/delete_weight.dart';
import 'package:life_tracker/features/health/domain/usecases/get_latest_weight.dart';
import 'package:life_tracker/features/health/domain/usecases/get_weights.dart';
import 'package:life_tracker/features/health/domain/usecases/update_weight.dart';

import 'package:life_tracker/features/health/health_providers.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_ideal_weight.dart';
final addWeightUseCaseProvider = Provider((ref) => AddWeight(ref.read(weightRepositoryProvider)));
final getWeightsUseCaseProvider = Provider((ref) => GetWeights(ref.read(weightRepositoryProvider)));
final getLatestWeightUseCaseProvider = Provider((ref) => GetLatestWeight(ref.read(weightRepositoryProvider)));
final updateWeightUseCaseProvider = Provider((ref) => UpdateWeight(ref.read(weightRepositoryProvider)));
final deleteWeightUseCaseProvider = Provider((ref) => DeleteWeight(ref.read(weightRepositoryProvider)));
final calculateBmiUseCaseProvider = Provider((ref) => CalculateBmi());

// StateNotifier for managing weight-related state
class WeightNotifier extends StateNotifier<AsyncValue<List<WeightEntry>>> {
  final AddWeight _addWeight;
  final GetWeights _getWeights;
  final UpdateWeight _updateWeight;
  final DeleteWeight _deleteWeight;
  final CalculateBmi _calculateBmi;

  WeightNotifier({
    required AddWeight addWeight,
    required GetWeights getWeights,
    required UpdateWeight updateWeight,
    required DeleteWeight deleteWeight,
    required CalculateBmi calculateBmi,
  })  : _addWeight = addWeight,
        _getWeights = getWeights,
        _updateWeight = updateWeight,
        _deleteWeight = deleteWeight,
        _calculateBmi = calculateBmi,
        super(const AsyncValue.loading()) {
    loadWeights();
  }

  Future<void> loadWeights() async {
    state = const AsyncValue.loading();
    final result = await _getWeights(const GetWeightsParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (weights) => AsyncValue.data(weights),
    );
  }

  Future<void> addWeightEntry(WeightEntry weightEntry) async {
    final result = await _addWeight(weightEntry);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) => loadWeights(), // Reload weights after adding
    );
  }

  Future<void> updateWeightEntry(WeightEntry weightEntry) async {
    final result = await _updateWeight(weightEntry);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadWeights(), // Reload weights after updating
    );
  }

  Future<void> deleteWeightEntry(Id id) async {
    final result = await _deleteWeight(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadWeights(), // Reload weights after deleting
    );
  }

  Future<double?> calculateBmi(double weight, double height) async {
    final result = await _calculateBmi(BmiParams(weight: weight, height: height));
    return result.fold(
      (failure) => null,
      (bmi) => bmi,
    );
  }
}

final weightNotifierProvider = StateNotifierProvider<WeightNotifier, AsyncValue<List<WeightEntry>>>((ref) {
  return WeightNotifier(
    addWeight: ref.read(addWeightUseCaseProvider),
    getWeights: ref.read(getWeightsUseCaseProvider),
    updateWeight: ref.read(updateWeightUseCaseProvider),
    deleteWeight: ref.read(deleteWeightUseCaseProvider),
    calculateBmi: ref.read(calculateBmiUseCaseProvider),
  );
});

final weightListProvider = Provider<AsyncValue<List<WeightEntry>>>((ref) {
  return ref.watch(weightNotifierProvider);
});

final latestWeightProvider = FutureProvider<WeightEntry?>((ref) async {
  final result = await ref.read(getLatestWeightUseCaseProvider)(NoParams());
  return result.fold(
    (failure) => throw failure,
    (weightEntry) => weightEntry,
  );
});

final bmiProvider = FutureProvider.family<double?, BmiParams>((ref, params) async {
  final result = await ref.read(calculateBmiUseCaseProvider)(params);
  return result.fold(
    (failure) => null,
    (bmi) => bmi,
  );
});

final idealWeightProvider = FutureProvider.family<Map<String, double>?, IdealWeightParams>((ref, params) async {
  final result = await ref.read(calculateIdealWeightUseCaseProvider)(params);
  return result.fold(
    (failure) => null,
    (idealWeight) => idealWeight,
  );
});
