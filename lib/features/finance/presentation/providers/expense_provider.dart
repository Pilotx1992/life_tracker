import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_expense.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_total_expenses.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_expense.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_expenses.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_expenses_by_category.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_expenses_by_date_range.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_expense.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';

// Providers for use cases (dependency injection)
final addExpenseUseCaseProvider =
    Provider((ref) => AddExpense(ref.read(expenseRepositoryProvider)));
final getExpensesUseCaseProvider =
    Provider((ref) => GetExpenses(ref.read(expenseRepositoryProvider)));
final updateExpenseUseCaseProvider =
    Provider((ref) => UpdateExpense(ref.read(expenseRepositoryProvider)));
final deleteExpenseUseCaseProvider =
    Provider((ref) => DeleteExpense(ref.read(expenseRepositoryProvider)));
final getExpensesByDateRangeUseCaseProvider = Provider(
  (ref) => GetExpensesByDateRange(ref.read(expenseRepositoryProvider)),
);
final getExpensesByCategoryUseCaseProvider = Provider(
  (ref) => GetExpensesByCategory(ref.read(expenseRepositoryProvider)),
);
final calculateTotalExpensesUseCaseProvider = Provider(
  (ref) => CalculateTotalExpenses(ref.read(expenseRepositoryProvider)),
);

// StateNotifier for managing expense-related state
class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final AddExpense _addExpense;
  final GetExpenses _getExpenses;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;
  final GetExpensesByDateRange _getExpensesByDateRange;
  final GetExpensesByCategory _getExpensesByCategory;
  final CalculateTotalExpenses _calculateTotalExpenses;

  ExpenseNotifier({
    required AddExpense addExpense,
    required GetExpenses getExpenses,
    required UpdateExpense updateExpense,
    required DeleteExpense deleteExpense,
    required GetExpensesByDateRange getExpensesByDateRange,
    required GetExpensesByCategory getExpensesByCategory,
    required CalculateTotalExpenses calculateTotalExpenses,
  })  : _addExpense = addExpense,
        _getExpenses = getExpenses,
        _updateExpense = updateExpense,
        _deleteExpense = deleteExpense,
        _getExpensesByDateRange = getExpensesByDateRange,
        _getExpensesByCategory = getExpensesByCategory,
        _calculateTotalExpenses = calculateTotalExpenses,
        super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    final result = await _getExpenses(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (expenses) => AsyncValue.data(expenses),
    );
  }

  Future<void> loadExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = const AsyncValue.loading();
    final result = await _getExpensesByDateRange(
      GetExpensesByDateRangeParams(startDate: startDate, endDate: endDate),
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (expenses) => AsyncValue.data(expenses),
    );
  }

  Future<void> loadExpensesByCategory(Id categoryId) async {
    state = const AsyncValue.loading();
    final result = await _getExpensesByCategory(
      GetExpensesByCategoryParams(categoryId: categoryId),
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (expenses) => AsyncValue.data(expenses),
    );
  }

  Future<void> addExpenseEntry(Expense expense) async {
    final result = await _addExpense(expense);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) => loadExpenses(), // Reload expenses after adding
    );
  }

  Future<void> updateExpenseEntry(Expense expense) async {
    final result = await _updateExpense(expense);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadExpenses(), // Reload expenses after updating
    );
  }

  Future<void> deleteExpenseEntry(Id id) async {
    final result = await _deleteExpense(DeleteExpenseParams(id: id));
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadExpenses(), // Reload expenses after deleting
    );
  }

  Future<double?> getTotalExpenses(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final result = await _calculateTotalExpenses(
      CalculateTotalExpensesParams(startDate: startDate, endDate: endDate),
    );
    return result.fold(
      (failure) => null,
      (total) => total,
    );
  }
}

final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
  return ExpenseNotifier(
    addExpense: ref.read(addExpenseUseCaseProvider),
    getExpenses: ref.read(getExpensesUseCaseProvider),
    updateExpense: ref.read(updateExpenseUseCaseProvider),
    deleteExpense: ref.read(deleteExpenseUseCaseProvider),
    getExpensesByDateRange: ref.read(getExpensesByDateRangeUseCaseProvider),
    getExpensesByCategory: ref.read(getExpensesByCategoryUseCaseProvider),
    calculateTotalExpenses: ref.read(calculateTotalExpensesUseCaseProvider),
  );
});

final expenseListProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  return ref.watch(expenseNotifierProvider);
});

final monthlyExpensesProvider =
    FutureProvider.family<double?, DateTime>((ref, month) async {
  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final notifier = ref.read(expenseNotifierProvider.notifier);
  return await notifier.getTotalExpenses(startDate, endDate);
});
