import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_debt.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_debt_payment.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_net_position.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_total_debts.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_debt.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_debt_payments.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_debts.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_debt.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/services/debt_notification_service.dart';
import 'package:life_tracker/core/providers/notification_provider.dart';

// Providers for use cases (dependency injection)
final addDebtUseCaseProvider =
    Provider((ref) => AddDebt(ref.read(debtRepositoryProvider)));
final getDebtsUseCaseProvider =
    Provider((ref) => GetDebts(ref.read(debtRepositoryProvider)));
final updateDebtUseCaseProvider =
    Provider((ref) => UpdateDebt(ref.read(debtRepositoryProvider)));
final deleteDebtUseCaseProvider =
    Provider((ref) => DeleteDebt(ref.read(debtRepositoryProvider)));
final calculateTotalDebtsUseCaseProvider =
    Provider((ref) => CalculateTotalDebts(ref.read(debtRepositoryProvider)));
final calculateNetPositionUseCaseProvider =
    Provider((ref) => CalculateNetPosition(ref.read(debtRepositoryProvider)));
final addDebtPaymentUseCaseProvider =
    Provider((ref) => AddDebtPayment(ref.read(debtRepositoryProvider)));
final getDebtPaymentsUseCaseProvider =
    Provider((ref) => GetDebtPayments(ref.read(debtRepositoryProvider)));

// StateNotifier for managing debt-related state
class DebtNotifier extends StateNotifier<AsyncValue<List<Debt>>> {
  final AddDebt _addDebt;
  final GetDebts _getDebts;
  final UpdateDebt _updateDebt;
  final DeleteDebt _deleteDebt;
  final CalculateTotalDebts _calculateTotalDebts;
  final CalculateNetPosition _calculateNetPosition;
  final AddDebtPayment _addDebtPayment;
  final GetDebtPayments _getDebtPayments;
  final DebtNotificationService? _notificationService;

  DebtNotifier({
    required AddDebt addDebt,
    required GetDebts getDebts,
    required UpdateDebt updateDebt,
    required DeleteDebt deleteDebt,
    required CalculateTotalDebts calculateTotalDebts,
    required CalculateNetPosition calculateNetPosition,
    required AddDebtPayment addDebtPayment,
    required GetDebtPayments getDebtPayments,
    DebtNotificationService? notificationService,
  })  : _addDebt = addDebt,
        _notificationService = notificationService,
        _getDebts = getDebts,
        _updateDebt = updateDebt,
        _deleteDebt = deleteDebt,
        _calculateTotalDebts = calculateTotalDebts,
        _calculateNetPosition = calculateNetPosition,
        _addDebtPayment = addDebtPayment,
        _getDebtPayments = getDebtPayments,
        super(const AsyncValue.loading());

  Future<void> loadDebts({String? type}) async {
    // Always load all debts, filtering will be done in the provider
    state = const AsyncValue.loading();
    final result = await _getDebts(const GetDebtsParams(type: null));
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (debts) => AsyncValue.data(debts),
    );
  }

  Future<void> addDebtEntry(Debt debt) async {
    final result = await _addDebt(debt);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) async {
        // Schedule reminder notification
        if (_notificationService != null && debt.id != null) {
          await _notificationService.scheduleDebtReminder(debt);
        }
        loadDebts(); // Reload all debts after adding
      },
    );
  }

  Future<void> updateDebtEntry(Debt debt) async {
    final result = await _updateDebt(debt);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Update reminder notification
        if (_notificationService != null && debt.id != null) {
          if (debt.isPaid) {
            await _notificationService.cancelDebtReminder(debt.id!);
          } else {
            await _notificationService.scheduleDebtReminder(debt);
          }
        }
        loadDebts(); // Reload all debts after updating
      },
    );
  }

  Future<void> deleteDebtEntry(Id id, String type) async {
    final result = await _deleteDebt(DeleteDebtParams(id: id));
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Cancel reminder notification
        if (_notificationService != null) {
          await _notificationService.cancelDebtReminder(id);
        }
        loadDebts(); // Reload all debts after deleting
      },
    );
  }

  Future<double?> getTotalDebts(String type) async {
    final result =
        await _calculateTotalDebts(CalculateTotalDebtsParams(type: type));
    return result.fold(
      (failure) => null,
      (total) => total,
    );
  }

  Future<double?> getNetPosition() async {
    final result = await _calculateNetPosition(NoParams());
    return result.fold(
      (failure) => null,
      (net) => net,
    );
  }

  Future<void> addPayment(DebtPayment payment) async {
    final result = await _addDebtPayment(payment);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) async {
        // Reload the specific debt to get updated paid amount
        final debtResult = await _getDebts(const GetDebtsParams());
        debtResult.fold(
          (failure) => state = AsyncValue.error(failure, StackTrace.current),
          (debts) => state = AsyncValue.data(debts),
        );
      },
    );
  }

  Future<List<DebtPayment>> getPayments(Id debtId) async {
    final result =
        await _getDebtPayments(GetDebtPaymentsParams(debtId: debtId));
    return result.fold(
      (failure) => [],
      (payments) => payments,
    );
  }
}

final debtNotificationServiceProvider =
    Provider<DebtNotificationService>((ref) {
  return DebtNotificationService(ref.read(notificationServiceProvider));
});

final debtNotifierProvider =
    StateNotifierProvider<DebtNotifier, AsyncValue<List<Debt>>>((ref) {
  final notifier = DebtNotifier(
    addDebt: ref.read(addDebtUseCaseProvider),
    getDebts: ref.read(getDebtsUseCaseProvider),
    updateDebt: ref.read(updateDebtUseCaseProvider),
    deleteDebt: ref.read(deleteDebtUseCaseProvider),
    calculateTotalDebts: ref.read(calculateTotalDebtsUseCaseProvider),
    calculateNetPosition: ref.read(calculateNetPositionUseCaseProvider),
    addDebtPayment: ref.read(addDebtPaymentUseCaseProvider),
    getDebtPayments: ref.read(getDebtPaymentsUseCaseProvider),
    notificationService: ref.read(debtNotificationServiceProvider),
  );
  // Load debts after the notifier is created, not in constructor
  Future.microtask(() => notifier.loadDebts());
  return notifier;
});

final debtListProvider =
    Provider.family<AsyncValue<List<Debt>>, String?>((ref, type) {
  final allDebtsAsync = ref.watch(debtNotifierProvider);
  final accountsAsync = ref.watch(accountListProvider);

  return allDebtsAsync.when(
    data: (allDebts) {
      // Get Credit Card accounts and calculate debt using utilized limit
      final creditCardDebts = accountsAsync.when(
        data: (accounts) {
          return accounts
              .where((account) => account.type == 'Credit Card')
              .map((account) {
                final creditLimit = account.creditLimit ?? 0.0;

                // Utilized limit = creditLimit - balance (this is the current debt)
                // Because: balance decreases when expenses are added, and increases when payment is made
                final utilizedLimit =
                    creditLimit > 0 && account.balance < creditLimit
                        ? creditLimit - account.balance
                        : 0.0;

                // Only show if there's actual debt (utilized limit > 0)
                if (utilizedLimit <= 0) return null;

                // For Credit Card:
                // - creditLimit = the original credit limit (stored in account.creditLimit)
                // - currentDebt = utilizedLimit = creditLimit - balance
                // - amount = creditLimit (the original credit limit to show in "of $amount")
                // - paidAmount = creditLimit - utilizedLimit = balance (how much has been paid)
                // - remainingAmount = utilizedLimit (what's still owed, shown as main amount)
                final paidAmount = creditLimit - utilizedLimit;

                return Debt(
                  id: account.id, // Use account ID as debt ID for uniqueness
                  type: 'i_owe',
                  amount:
                      creditLimit, // Original credit limit (to show in "of $amount")
                  paidAmount:
                      paidAmount, // Amount already paid (creditLimit - utilizedLimit)
                  person: account.name,
                  dueDate: DateTime.now()
                      .add(const Duration(days: 30)), // Default due date
                  note: 'Credit Card Debt',
                  isPaid:
                      utilizedLimit <= 0, // Mark as paid if no debt remaining
                );
              })
              .whereType<Debt>()
              .toList();
        },
        loading: () => <Debt>[],
        error: (_, __) => <Debt>[],
      );

      // Combine regular debts with credit card debts
      final List<Debt> combinedDebts = List.from(allDebts);

      // Add credit card debts only to "I Owe" tab
      if (type == 'i_owe') {
        // Filter out any regular debts that might have the same ID as a credit card
        final existingDebtIds = combinedDebts.map((d) => d.id).toSet();
        // Add credit card debts that don't already exist (show all, including paid ones)
        combinedDebts.addAll(
          creditCardDebts
              .where((ccDebt) => !existingDebtIds.contains(ccDebt.id)),
        );
      }

      if (type == null) {
        return AsyncValue.data(combinedDebts);
      }

      // Filter by type - show all debts regardless of payment status
      final filteredDebts =
          combinedDebts.where((debt) => debt.type == type).toList();
      return AsyncValue.data(filteredDebts);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final totalIOweProvider = Provider<double?>((ref) {
  final debtsAsync = ref.watch(debtNotifierProvider);
  final accountsAsync = ref.watch(accountListProvider);

  // Calculate regular debts total
  final regularDebtsTotal = debtsAsync.when(
    data: (debts) {
      final iOweDebts = debts.where((d) => d.type == 'i_owe');
      return iOweDebts.fold<double>(
        0.0,
        (sum, debt) => sum + (debt.amount - debt.paidAmount),
      );
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );

  // Calculate Credit Card debts using utilized limit (creditLimit - balance)
  final creditCardTotal = accountsAsync.when(
    data: (accounts) {
      return accounts
          .where((account) => account.type == 'Credit Card')
          .fold<double>(
        0.0,
        (sum, account) {
          final creditLimit = account.creditLimit ?? 0.0;
          // Utilized limit = creditLimit - balance (this is the current debt)
          // Because: balance decreases when expenses are added, and increases when payment is made
          // If balance < creditLimit, there is debt
          if (creditLimit > 0 && account.balance < creditLimit) {
            final utilizedLimit = creditLimit - account.balance;
            return sum + utilizedLimit;
          }
          return sum;
        },
      );
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );

  final total = regularDebtsTotal + creditCardTotal;
  return total > 0 ? total : null;
});

final totalOwedToMeProvider = Provider<double?>((ref) {
  final debtsAsync = ref.watch(debtNotifierProvider);
  return debtsAsync.when(
    data: (debts) {
      final owedToMeDebts = debts.where((d) => d.type == 'owed_to_me');
      final total = owedToMeDebts.fold<double>(
        0.0,
        (sum, debt) => sum + (debt.amount - debt.paidAmount),
      );
      return total > 0 ? total : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final netPositionProvider = Provider<double?>((ref) {
  final iOweTotal = ref.watch(totalIOweProvider);
  final owedToMeTotal = ref.watch(totalOwedToMeProvider);

  if (iOweTotal == null && owedToMeTotal == null) {
    return null;
  }

  final iOwe = iOweTotal ?? 0.0;
  final owedToMe = owedToMeTotal ?? 0.0;

  // Net position = owed to me - I owe
  // Positive means you are owed money, negative means you owe money
  return owedToMe - iOwe;
});

/// Total Assets Provider
/// Combines account balances + "owed to me" debts (receivables)
/// This represents total assets regardless of whether money has been collected
final totalAssetsProvider = Provider<double?>((ref) {
  final accountBalance = ref.watch(totalBalanceProvider);
  final owedToMe = ref.watch(totalOwedToMeProvider);

  final balance = accountBalance ?? 0.0;
  final receivables = owedToMe ?? 0.0;

  final total = balance + receivables;
  return total > 0 ? total : null;
});
