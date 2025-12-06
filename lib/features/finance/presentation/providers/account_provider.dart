import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_account.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_total_balance.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_account.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_accounts.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_account.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';

// Providers for use cases (dependency injection)
final addAccountUseCaseProvider =
    Provider((ref) => AddAccount(ref.read(accountRepositoryProvider)));
final getAccountsUseCaseProvider =
    Provider((ref) => GetAccounts(ref.read(accountRepositoryProvider)));
final updateAccountUseCaseProvider =
    Provider((ref) => UpdateAccount(ref.read(accountRepositoryProvider)));
final deleteAccountUseCaseProvider =
    Provider((ref) => DeleteAccount(ref.read(accountRepositoryProvider)));
final calculateTotalBalanceUseCaseProvider = Provider(
  (ref) => CalculateTotalBalance(ref.read(accountRepositoryProvider)),
);

// StateNotifier for managing account-related state
class AccountNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  final AddAccount _addAccount;
  final GetAccounts _getAccounts;
  final UpdateAccount _updateAccount;
  final DeleteAccount _deleteAccount;
  final CalculateTotalBalance _calculateTotalBalance;

  AccountNotifier({
    required AddAccount addAccount,
    required GetAccounts getAccounts,
    required UpdateAccount updateAccount,
    required DeleteAccount deleteAccount,
    required CalculateTotalBalance calculateTotalBalance,
  })  : _addAccount = addAccount,
        _getAccounts = getAccounts,
        _updateAccount = updateAccount,
        _deleteAccount = deleteAccount,
        _calculateTotalBalance = calculateTotalBalance,
        super(const AsyncValue.loading()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    state = const AsyncValue.loading();
    final result = await _getAccounts(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (accounts) => AsyncValue.data(accounts),
    );
  }

  Future<void> addAccountEntry(Account account) async {
    final result = await _addAccount(account);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) => loadAccounts(), // Reload accounts after adding
    );
  }

  Future<void> updateAccountEntry(Account account) async {
    final result = await _updateAccount(account);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadAccounts(), // Reload accounts after updating
    );
  }

  Future<void> deleteAccountEntry(Id id) async {
    final result = await _deleteAccount(DeleteAccountParams(id: id));
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadAccounts(), // Reload accounts after deleting
    );
  }

  Future<double?> getTotalBalance() async {
    final result = await _calculateTotalBalance(NoParams());
    return result.fold(
      (failure) => null,
      (total) => total,
    );
  }
}

final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, AsyncValue<List<Account>>>((ref) {
  return AccountNotifier(
    addAccount: ref.read(addAccountUseCaseProvider),
    getAccounts: ref.read(getAccountsUseCaseProvider),
    updateAccount: ref.read(updateAccountUseCaseProvider),
    deleteAccount: ref.read(deleteAccountUseCaseProvider),
    calculateTotalBalance: ref.read(calculateTotalBalanceUseCaseProvider),
  );
});

final accountListProvider = Provider<AsyncValue<List<Account>>>((ref) {
  return ref.watch(accountNotifierProvider);
});

final totalBalanceProvider = Provider<double?>((ref) {
  final accountsAsync = ref.watch(accountListProvider);
  return accountsAsync.when(
    data: (accounts) {
      // Exclude Credit Card accounts from total balance
      final regularAccounts =
          accounts.where((a) => a.type.toLowerCase() != 'credit card').toList();
      return regularAccounts.fold<double>(
        0.0,
        (sum, account) => sum + account.balance,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final creditCardTotalProvider = Provider<double?>((ref) {
  final accountsAsync = ref.watch(accountListProvider);
  return accountsAsync.when(
    data: (accounts) {
      final creditCards = accounts.where((a) => a.type == 'Credit Card');
      final total = creditCards.fold<double>(
        0.0,
        (sum, account) => sum + account.balance,
      );
      return total > 0 ? total : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
