import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_income.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_total_income.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_income.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_incomes.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_incomes_by_date_range.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_income.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';

// Providers for use cases (dependency injection)
final addIncomeUseCaseProvider =
    Provider((ref) => AddIncome(ref.read(incomeRepositoryProvider)));
final getIncomesUseCaseProvider =
    Provider((ref) => GetIncomes(ref.read(incomeRepositoryProvider)));
final updateIncomeUseCaseProvider =
    Provider((ref) => UpdateIncome(ref.read(incomeRepositoryProvider)));
final deleteIncomeUseCaseProvider =
    Provider((ref) => DeleteIncome(ref.read(incomeRepositoryProvider)));
final getIncomesByDateRangeUseCaseProvider = Provider(
  (ref) => GetIncomesByDateRange(ref.read(incomeRepositoryProvider)),
);
final calculateTotalIncomeUseCaseProvider =
    Provider((ref) => CalculateTotalIncome(ref.read(incomeRepositoryProvider)));

// StateNotifier for managing income-related state
class IncomeNotifier extends StateNotifier<AsyncValue<List<Income>>> {
  final AddIncome _addIncome;
  final GetIncomes _getIncomes;
  final UpdateIncome _updateIncome;
  final DeleteIncome _deleteIncome;
  final GetIncomesByDateRange _getIncomesByDateRange;
  final CalculateTotalIncome _calculateTotalIncome;

  IncomeNotifier({
    required AddIncome addIncome,
    required GetIncomes getIncomes,
    required UpdateIncome updateIncome,
    required DeleteIncome deleteIncome,
    required GetIncomesByDateRange getIncomesByDateRange,
    required CalculateTotalIncome calculateTotalIncome,
  })  : _addIncome = addIncome,
        _getIncomes = getIncomes,
        _updateIncome = updateIncome,
        _deleteIncome = deleteIncome,
        _getIncomesByDateRange = getIncomesByDateRange,
        _calculateTotalIncome = calculateTotalIncome,
        super(const AsyncValue.loading()) {
    loadIncomes();
  }

  Future<void> loadIncomes() async {
    state = const AsyncValue.loading();
    final result = await _getIncomes(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (incomes) => AsyncValue.data(incomes),
    );
  }

  Future<void> loadIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = const AsyncValue.loading();
    final result = await _getIncomesByDateRange(
      GetIncomesByDateRangeParams(startDate: startDate, endDate: endDate),
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (incomes) => AsyncValue.data(incomes),
    );
  }

  Future<void> addIncomeEntry(Income income) async {
    final result = await _addIncome(income);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) => loadIncomes(), // Reload incomes after adding
    );
  }

  Future<void> updateIncomeEntry(Income income) async {
    final result = await _updateIncome(income);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadIncomes(), // Reload incomes after updating
    );
  }

  Future<void> deleteIncomeEntry(Id id) async {
    final result = await _deleteIncome(DeleteIncomeParams(id: id));
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadIncomes(), // Reload incomes after deleting
    );
  }

  Future<double?> getTotalIncome(DateTime? startDate, DateTime? endDate) async {
    final result = await _calculateTotalIncome(
      CalculateTotalIncomeParams(startDate: startDate, endDate: endDate),
    );
    return result.fold(
      (failure) => null,
      (total) => total,
    );
  }
}

final incomeNotifierProvider =
    StateNotifierProvider<IncomeNotifier, AsyncValue<List<Income>>>((ref) {
  return IncomeNotifier(
    addIncome: ref.read(addIncomeUseCaseProvider),
    getIncomes: ref.read(getIncomesUseCaseProvider),
    updateIncome: ref.read(updateIncomeUseCaseProvider),
    deleteIncome: ref.read(deleteIncomeUseCaseProvider),
    getIncomesByDateRange: ref.read(getIncomesByDateRangeUseCaseProvider),
    calculateTotalIncome: ref.read(calculateTotalIncomeUseCaseProvider),
  );
});

final incomeListProvider = Provider<AsyncValue<List<Income>>>((ref) {
  return ref.watch(incomeNotifierProvider);
});

final monthlyIncomeProvider =
    FutureProvider.family<double?, DateTime>((ref, month) async {
  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final notifier = ref.read(incomeNotifierProvider.notifier);
  return await notifier.getTotalIncome(startDate, endDate);
});
