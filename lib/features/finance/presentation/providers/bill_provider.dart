import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/bill_payment.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_bill.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_bill_payment.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_next_due_date.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_bill.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_active_bills.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_bill_by_id.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_bill_payments.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_bills.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_overdue_bills.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_upcoming_bills.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_bill.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';
import 'package:life_tracker/features/finance/services/bill_notification_service.dart';
import 'package:life_tracker/core/providers/notification_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/expense_provider.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/reminders/services/linked_reminder_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';

// Providers for use cases (dependency injection)
final addBillUseCaseProvider =
    Provider((ref) => AddBill(ref.read(billRepositoryProvider)));
final getBillsUseCaseProvider =
    Provider((ref) => GetBills(ref.read(billRepositoryProvider)));
final getActiveBillsUseCaseProvider =
    Provider((ref) => GetActiveBills(ref.read(billRepositoryProvider)));
final getUpcomingBillsUseCaseProvider =
    Provider((ref) => GetUpcomingBills(ref.read(billRepositoryProvider)));
final getOverdueBillsUseCaseProvider =
    Provider((ref) => GetOverdueBills(ref.read(billRepositoryProvider)));
final getBillByIdUseCaseProvider =
    Provider((ref) => GetBillById(ref.read(billRepositoryProvider)));
final updateBillUseCaseProvider =
    Provider((ref) => UpdateBill(ref.read(billRepositoryProvider)));
final deleteBillUseCaseProvider =
    Provider((ref) => DeleteBill(ref.read(billRepositoryProvider)));
final addBillPaymentUseCaseProvider =
    Provider((ref) => AddBillPayment(ref.read(billRepositoryProvider)));
final getBillPaymentsUseCaseProvider =
    Provider((ref) => GetBillPayments(ref.read(billRepositoryProvider)));

// Notification service provider
final billNotificationServiceProvider =
    Provider<BillNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return BillNotificationService(notificationService);
});

// StateNotifier for managing bill-related state
class BillNotifier extends StateNotifier<AsyncValue<List<RecurringBill>>> {
  final AddBill _addBill;
  final GetBills _getBills;
  final GetActiveBills _getActiveBills;
  final GetUpcomingBills _getUpcomingBills;
  final GetOverdueBills _getOverdueBills;
  final GetBillById _getBillById;
  final UpdateBill _updateBill;
  final DeleteBill _deleteBill;
  final AddBillPayment _addBillPayment;
  final GetBillPayments _getBillPayments;
  final BillNotificationService? _notificationService;
  final ExpenseNotifier? _expenseNotifier;
  final AccountNotifier? _accountNotifier;
  final LinkedReminderService? _linkedReminderService;

  BillNotifier({
    required AddBill addBill,
    required GetBills getBills,
    required GetActiveBills getActiveBills,
    required GetUpcomingBills getUpcomingBills,
    required GetOverdueBills getOverdueBills,
    required GetBillById getBillById,
    required UpdateBill updateBill,
    required DeleteBill deleteBill,
    required AddBillPayment addBillPayment,
    required GetBillPayments getBillPayments,
    BillNotificationService? notificationService,
    ExpenseNotifier? expenseNotifier,
    AccountNotifier? accountNotifier,
    LinkedReminderService? linkedReminderService,
  })  : _addBill = addBill,
        _getBills = getBills,
        _getActiveBills = getActiveBills,
        _getUpcomingBills = getUpcomingBills,
        _getOverdueBills = getOverdueBills,
        _getBillById = getBillById,
        _updateBill = updateBill,
        _deleteBill = deleteBill,
        _addBillPayment = addBillPayment,
        _getBillPayments = getBillPayments,
        _notificationService = notificationService,
        _expenseNotifier = expenseNotifier,
        _accountNotifier = accountNotifier,
        _linkedReminderService = linkedReminderService,
        super(const AsyncValue.loading()) {
    loadBills();
  }

  Future<void> loadBills() async {
    state = const AsyncValue.loading();
    final result = await _getBills(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (bills) => AsyncValue.data(bills),
    );
  }

  Future<void> loadActiveBills() async {
    state = const AsyncValue.loading();
    final result = await _getActiveBills(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (bills) => AsyncValue.data(bills),
    );
  }

  Future<List<RecurringBill>> getUpcomingBills(DateTime endDate) async {
    final result = await _getUpcomingBills(endDate);
    return result.fold(
      (failure) => <RecurringBill>[],
      (bills) => bills,
    );
  }

  Future<List<RecurringBill>> getOverdueBills() async {
    final result = await _getOverdueBills(NoParams());
    return result.fold(
      (failure) => <RecurringBill>[],
      (bills) => bills,
    );
  }

  Future<RecurringBill?> getBillById(Id id) async {
    final result = await _getBillById(id);
    return result.fold(
      (failure) => null,
      (bill) => bill,
    );
  }

  Future<void> addBillEntry(RecurringBill bill) async {
    final result = await _addBill(bill);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) async {
        final billWithId = bill.copyWith(id: id);
        // Schedule reminder notification
        if (_notificationService != null) {
          await _notificationService.scheduleBillReminder(billWithId);
        }
        // Create linked reminder
        if (_linkedReminderService != null) {
          await _linkedReminderService.createBillReminder(billWithId);
        }
        loadBills(); // Reload bills after adding
      },
    );
  }

  Future<void> updateBillEntry(RecurringBill bill) async {
    final result = await _updateBill(bill);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Update reminder notification
        if (_notificationService != null && bill.id != null) {
          if (!bill.isActive) {
            await _notificationService.cancelBillReminder(bill.id!);
          } else {
            await _notificationService.scheduleBillReminder(bill);
          }
        }
        // Update linked reminder
        if (_linkedReminderService != null && bill.id != null) {
          if (!bill.isActive) {
            await _linkedReminderService.deleteLinkedReminders(
              'bill',
              bill.id!,
            );
          } else {
            await _linkedReminderService.updateBillReminder(bill);
          }
        }
        loadBills(); // Reload bills after updating
      },
    );
  }

  Future<void> deleteBillEntry(Id id) async {
    final result = await _deleteBill(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Cancel reminder notification
        if (_notificationService != null) {
          await _notificationService.cancelBillReminder(id);
        }
        // Delete linked reminders
        if (_linkedReminderService != null) {
          await _linkedReminderService.deleteLinkedReminders('bill', id);
        }
        loadBills(); // Reload bills after deleting
      },
    );
  }

  /// Marks a bill as paid, creates an expense, and schedules the next occurrence.
  Future<void> markBillAsPaid(RecurringBill bill, {String? note}) async {
    if (bill.id == null) return;

    // Create a bill payment record
    final payment = BillPayment(
      billId: bill.id!,
      paidDate: DateTime.now(),
      amount: bill.amount,
      note: note,
    );

    final paymentResult = await _addBillPayment(payment);
    await paymentResult.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (paymentId) async {
        // Auto-create expense
        if (_expenseNotifier != null) {
          final expense = Expense(
            amount: bill.amount,
            currency: bill.currency,
            categoryId: bill.categoryId,
            accountId: bill.accountId,
            date: DateTime.now(),
            note: note ?? 'Recurring bill: ${bill.name}',
          );
          await _expenseNotifier.addExpenseEntry(expense);

          // Update account balance
          if (_accountNotifier != null) {
            final accountsState = _accountNotifier.state;
            if (accountsState is AsyncData<List<Account>>) {
              final accounts = accountsState.value;
              try {
                final account =
                    accounts.firstWhere((a) => a.id == bill.accountId);
                final updatedAccount = account.copyWith(
                  balance: account.balance - bill.amount,
                );
                await _accountNotifier.updateAccountEntry(updatedAccount);
              } catch (e) {
                // Account not found or other error, ignore
              }
            }
          }
        }

        // For installments, update paid amount
        if (bill.isInstallment) {
          final updatedBill = bill.copyWith(
            paidAmount: bill.paidAmount + bill.amount,
            paidInstallments: bill.paidInstallments + 1,
          );

          // Check if fully paid
          if (updatedBill.remainingAmount <= 0) {
            await updateBillEntry(updatedBill.copyWith(isActive: false));
          } else {
            // Calculate next due date
            final nextDueDate = CalculateNextDueDate.calculate(updatedBill);
            await updateBillEntry(
                updatedBill.copyWith(nextDueDate: nextDueDate),);
          }
        } else {
          // For recurring bills, just update next due date
          // Calculate from the current nextDueDate to maintain the schedule
          final nextDueDate = CalculateNextDueDate.calculate(
            bill,
            fromDate: bill.nextDueDate,
          );
          final updatedBill = bill.copyWith(nextDueDate: nextDueDate);
          await updateBillEntry(updatedBill);
        }
      },
    );
  }

  /// ✨ Make a custom payment for an installment (partial or full)
  Future<void> makeInstallmentPayment(
    RecurringBill bill, {
    required double amount,
    String? note,
  }) async {
    if (bill.id == null || !bill.isInstallment) return;

    // Create a bill payment record
    final payment = BillPayment(
      billId: bill.id!,
      paidDate: DateTime.now(),
      amount: amount,
      note: note,
    );

    final paymentResult = await _addBillPayment(payment);
    await paymentResult.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (paymentId) async {
        // Auto-create expense
        if (_expenseNotifier != null) {
          final expense = Expense(
            amount: amount,
            currency: bill.currency,
            categoryId: bill.categoryId,
            accountId: bill.accountId,
            date: DateTime.now(),
            note: note ?? 'Installment payment: ${bill.name}',
          );
          await _expenseNotifier.addExpenseEntry(expense);

          // Update account balance
          if (_accountNotifier != null) {
            final accountsState = _accountNotifier.state;
            if (accountsState is AsyncData<List<Account>>) {
              final accounts = accountsState.value;
              try {
                final account =
                    accounts.firstWhere((a) => a.id == bill.accountId);
                final updatedAccount = account.copyWith(
                  balance: account.balance - amount,
                );
                await _accountNotifier.updateAccountEntry(updatedAccount);
              } catch (e) {
                // Account not found or other error, ignore
              }
            }
          }
        }

        // Update paid amount
        final newPaidAmount = bill.paidAmount + amount;
        final updatedBill = bill.copyWith(
          paidAmount: newPaidAmount,
          paidInstallments: bill.paidInstallments + 1,
        );

        // Check if fully paid
        if (updatedBill.remainingAmount <= 0) {
          await updateBillEntry(updatedBill.copyWith(isActive: false));
        } else {
          // Calculate next due date
          final nextDueDate = CalculateNextDueDate.calculate(updatedBill);
          await updateBillEntry(updatedBill.copyWith(nextDueDate: nextDueDate));
        }
      },
    );
  }

  Future<List<BillPayment>> getPaymentsByBill(Id billId) async {
    final result = await _getBillPayments(billId);
    return result.fold(
      (failure) => <BillPayment>[],
      (payments) => payments,
    );
  }

  /// ✨ Get only installment-type bills
  List<RecurringBill> getInstallments() {
    return state.maybeWhen(
      data: (bills) => bills.where((b) => b.isInstallment).toList(),
      orElse: () => <RecurringBill>[],
    );
  }

  /// ✨ Get only recurring-type bills
  List<RecurringBill> getRecurringBills() {
    return state.maybeWhen(
      data: (bills) => bills.where((b) => !b.isInstallment).toList(),
      orElse: () => <RecurringBill>[],
    );
  }

  /// ✨ Get active (not fully paid) installments
  List<RecurringBill> getActiveInstallments() {
    return state.maybeWhen(
      data: (bills) => bills
          .where((b) => b.isInstallment && b.isActive && !b.isFullyPaid)
          .toList(),
      orElse: () => <RecurringBill>[],
    );
  }

  /// ✨ Get total remaining amount for all installments
  double getTotalRemainingInstallments() {
    return state.maybeWhen(
      data: (bills) => bills
          .where((b) => b.isInstallment && b.isActive)
          .fold<double>(0.0, (sum, b) => sum + b.remainingAmount),
      orElse: () => 0.0,
    );
  }
}

final billNotifierProvider =
    StateNotifierProvider<BillNotifier, AsyncValue<List<RecurringBill>>>((ref) {
  return BillNotifier(
    addBill: ref.read(addBillUseCaseProvider),
    getBills: ref.read(getBillsUseCaseProvider),
    getActiveBills: ref.read(getActiveBillsUseCaseProvider),
    getUpcomingBills: ref.read(getUpcomingBillsUseCaseProvider),
    getOverdueBills: ref.read(getOverdueBillsUseCaseProvider),
    getBillById: ref.read(getBillByIdUseCaseProvider),
    updateBill: ref.read(updateBillUseCaseProvider),
    deleteBill: ref.read(deleteBillUseCaseProvider),
    addBillPayment: ref.read(addBillPaymentUseCaseProvider),
    getBillPayments: ref.read(getBillPaymentsUseCaseProvider),
    notificationService: ref.read(billNotificationServiceProvider),
    expenseNotifier: ref.read(expenseNotifierProvider.notifier),
    accountNotifier: ref.read(accountNotifierProvider.notifier),
  );
});

// ✨ Convenience providers for installments
final installmentsProvider = Provider<List<RecurringBill>>((ref) {
  final billsAsync = ref.watch(billNotifierProvider);
  return billsAsync.maybeWhen(
    data: (bills) => bills.where((b) => b.isInstallment).toList(),
    orElse: () => <RecurringBill>[],
  );
});

final activeInstallmentsProvider = Provider<List<RecurringBill>>((ref) {
  final billsAsync = ref.watch(billNotifierProvider);
  return billsAsync.maybeWhen(
    data: (bills) => bills
        .where((b) => b.isInstallment && b.isActive && !b.isFullyPaid)
        .toList(),
    orElse: () => <RecurringBill>[],
  );
});

final totalRemainingInstallmentsProvider = Provider<double>((ref) {
  final billsAsync = ref.watch(billNotifierProvider);
  return billsAsync.maybeWhen(
    data: (bills) => bills
        .where((b) => b.isInstallment && b.isActive)
        .fold<double>(0.0, (sum, b) => sum + b.remainingAmount),
    orElse: () => 0.0,
  );
});

final recurringBillsProvider = Provider<List<RecurringBill>>((ref) {
  final billsAsync = ref.watch(billNotifierProvider);
  return billsAsync.maybeWhen(
    data: (bills) => bills.where((b) => !b.isInstallment).toList(),
    orElse: () => <RecurringBill>[],
  );
});
