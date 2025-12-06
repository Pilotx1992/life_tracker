import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/app_startup.dart';
import 'package:life_tracker/features/health/data/datasources/weight_local_data_source.dart';
import 'package:life_tracker/features/health/data/repositories/weight_repository_impl.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/usecases/add_weight.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_bmi.dart';
import 'package:life_tracker/features/health/domain/usecases/delete_weight.dart';
import 'package:life_tracker/features/health/domain/usecases/get_weights.dart';

// Data Source Provider - Fixed to handle async properly
final weightLocalDataSourceProvider = FutureProvider((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return WeightLocalDataSourceImpl(isarInstance: isar);
});

// Repository Provider - Fixed to handle async properly
final weightRepositoryProvider = FutureProvider((ref) async {
  final dataSource = await ref.watch(weightLocalDataSourceProvider.future);
  return WeightRepositoryImpl(dataSource);
});

// Use Cases Providers - Fixed to handle async repository
final getWeightsUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return GetWeights(repository);
});

final addWeightUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return AddWeight(repository);
});

final deleteWeightUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return DeleteWeight(repository);
});

final calculateBmiUseCaseProvider = Provider((ref) => CalculateBmi());

// State Providers

/// Weight list state provider - Fixed to handle async use cases
final weightListProvider =
    StateNotifierProvider<WeightListNotifier, AsyncValue<List<WeightEntry>>>(
  (ref) {
    // Watch the async values of use cases
    final getWeightsAsync = ref.watch(getWeightsUseCaseProvider);
    final addWeightAsync = ref.watch(addWeightUseCaseProvider);
    final deleteWeightAsync = ref.watch(deleteWeightUseCaseProvider);

    // Return loading state while use cases are initializing
    return getWeightsAsync.when(
      data: (getWeights) => addWeightAsync.when(
        data: (addWeight) => deleteWeightAsync.when(
          data: (deleteWeight) => WeightListNotifier(
            getWeights: getWeights,
            addWeight: addWeight,
            deleteWeight: deleteWeight,
          ),
          loading: () => WeightListNotifier.loading(),
          error: (e, s) => WeightListNotifier.loading(),
        ),
        loading: () => WeightListNotifier.loading(),
        error: (e, s) => WeightListNotifier.loading(),
      ),
      loading: () => WeightListNotifier.loading(),
      error: (e, s) => WeightListNotifier.loading(),
    );
  },
);

class WeightListNotifier extends StateNotifier<AsyncValue<List<WeightEntry>>> {
  final GetWeights? getWeights;
  final AddWeight? addWeight;
  final DeleteWeight? deleteWeightUseCase;

  WeightListNotifier({
    required this.getWeights,
    required this.addWeight,
    required DeleteWeight? deleteWeight,
  })  : deleteWeightUseCase = deleteWeight,
        super(const AsyncValue.loading()) {
    if (getWeights != null) {
      loadWeights();
    }
  }

  // Loading constructor for when dependencies are not ready
  WeightListNotifier.loading()
      : getWeights = null,
        addWeight = null,
        deleteWeightUseCase = null,
        super(const AsyncValue.loading());

  Future<void> loadWeights() async {
    if (getWeights == null) return;

    state = const AsyncValue.loading();

  final result = await getWeights!(const GetWeightsParams());

    result.fold(
      (failure) => state = AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      (weights) => state = AsyncValue.data(weights),
    );
  }

  Future<bool> addNewWeight(double weight, DateTime date, String? note) async {
    if (addWeight == null) return false;

      final weightEntry = WeightEntry(
        id: null,
        weight: weight,
        date: date,
        note: note,
      );

  final result = await addWeight!(weightEntry);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        loadWeights();
        return true;
      },
    );
  }

  Future<bool> deleteWeight(int id) async {
    if (deleteWeightUseCase == null) return false;

  final result = await deleteWeightUseCase!(id);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        loadWeights();
        return true;
      },
    );
  }
}

/// Latest weight provider
final latestWeightProvider = Provider<WeightEntry?>((ref) {
  final weightList = ref.watch(weightListProvider);

  return weightList.when(
    data: (weights) => weights.isNotEmpty ? weights.first : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// BMI provider (requires user height from settings - for now we'll use a default)
final bmiProvider = FutureProvider<double?>((ref) async {
  final latestWeight = ref.watch(latestWeightProvider);
  final calculateBmi = ref.read(calculateBmiUseCaseProvider);

  if (latestWeight == null) return null;

  // TODO: Get height from user profile settings
  // For now, using a default height of 170 cm
  const defaultHeight = 170.0;

  final either = await calculateBmi(BmiParams(weight: latestWeight.weight, height: defaultHeight));
  return either.fold((_) => null, (bmi) => bmi);
});
