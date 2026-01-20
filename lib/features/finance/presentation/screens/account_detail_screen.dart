import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/expense_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/income_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/transfer_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/category_provider.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_account_dialog.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_income_dialog.dart';
import 'package:life_tracker/features/finance/presentation/widgets/pay_credit_card_dialog.dart';

class AccountDetailScreen extends ConsumerWidget {
  final Account account;

  const AccountDetailScreen({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Get updated account from provider if available
    final accountsAsync = ref.watch(accountListProvider);
    final Account currentAccount = accountsAsync.when(
      data: (accounts) {
        return accounts.firstWhere(
          (a) => a.id == account.id,
          orElse: () => account,
        );
      },
      loading: () => account,
      error: (_, __) => account,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentAccount.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Account',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddAccountDialog(account: currentAccount),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Account',
            onPressed: () => _confirmDelete(context, ref, currentAccount),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: AppDesignTokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Credit Card Display (if Credit Card type)
            if (currentAccount.type == 'Credit Card' &&
                currentAccount.creditLimit != null)
              _buildCreditCardDisplay(
                context,
                ref,
                currentAccount,
                currencyFormat,
              )
            else
              // Balance Card (for other account types) - Premium Design
              _buildBalanceCard(context, currentAccount, currencyFormat),
            // Pay Credit Card Button (إذا كان الحساب Credit Card)
            if (currentAccount.type == 'Credit Card' &&
                currentAccount.balance > 0) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PayCreditCardDialog(
                        creditCardAccount: currentAccount,
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDesignTokens.space16),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppDesignTokens.space12),
                  Row(
                    children: [
                      // Add Expense Button
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          icon: Icons.remove_circle_outline,
                          label: 'Expense',
                          color: Colors.red,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => AddExpenseBottomSheet(
                                preSelectedAccountId: currentAccount.id,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add Income Button
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          icon: Icons.add_circle_outline,
                          label: 'Income',
                          color: Colors.green,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddIncomeDialog(
                                preSelectedAccountId: currentAccount.id,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Transfer Button
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          icon: Icons.swap_horiz_rounded,
                          label: 'Transfer',
                          color: Colors.blue,
                          onTap: () {
                            _showTransferDialog(context, ref, currentAccount);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),

            // Transaction Summary Section
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.space16),
              child: Text(
                'Transaction Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.space8),
            _buildTransactionList(
              context,
              ref,
              currentAccount,
              currencyFormat,
            ),
            const SizedBox(height: AppDesignTokens.space24),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${account.name}"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will also delete all related transactions',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccountEntry(account.id!);
      if (context.mounted) {
        Navigator.of(context).pop();
        FeedbackService.showSuccess(context, 'Account deleted');
      }
    }
  }

  Future<void> _showTransferDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final accountsAsync = ref.read(accountListProvider);
    final accounts = accountsAsync.value ?? [];

    if (accounts.length < 2) {
      if (context.mounted) {
        FeedbackService.showWarning(
          context,
          'You need at least 2 accounts to transfer money',
        );
      }
      return;
    }

    final otherAccounts = accounts.where((a) => a.id != account.id).toList();
    Account? selectedAccount;
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Transfer Money'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Account>(
                    decoration: const InputDecoration(
                      labelText: 'To Account',
                    ),
                    items: otherAccounts.map((acc) {
                      return DropdownMenuItem<Account>(
                        value: acc,
                        child: Text(acc.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAccount = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    selectedAccount != null && amountController.text.isNotEmpty
                        ? () => Navigator.of(context).pop(true)
                        : null,
                child: const Text('Transfer'),
              ),
            ],
          ),
        ),
      );

      if (result == true && selectedAccount != null) {
        final amount = double.tryParse(amountController.text);
        if (amount != null && amount > 0 && amount <= account.balance) {
          // Create transfer record
          final transfer = Transfer(
            amount: amount,
            currency: account.currency,
            fromAccountId: account.id!,
            toAccountId: selectedAccount!.id!,
            date: DateTime.now(),
            note: noteController.text.trim().isEmpty
                ? null
                : noteController.text.trim(),
          );

          // Save transfer
          await ref
              .read(transferNotifierProvider.notifier)
              .addTransferEntry(transfer);

          // Update source account (decrease balance)
          await ref.read(accountNotifierProvider.notifier).updateAccountEntry(
                account.copyWith(balance: account.balance - amount),
              );

          // Update destination account (increase balance)
          await ref.read(accountNotifierProvider.notifier).updateAccountEntry(
                selectedAccount!.copyWith(
                  balance: selectedAccount!.balance + amount,
                ),
              );

          if (context.mounted) {
            // Refresh accounts list
            ref.read(accountNotifierProvider.notifier).loadAccounts();

            FeedbackService.showSuccess(
              context,
              'Transferred \$${amount.toStringAsFixed(2)} to ${selectedAccount!.name}',
            );

            // Pop transfer dialog
            Navigator.of(context).pop();

            // The screen will automatically update via the provider watch
          }
        } else if (amount != null && amount > account.balance) {
          if (context.mounted) {
            FeedbackService.showError(context, 'Insufficient balance');
          }
        }
      }
    }
  }

  Widget _buildBalanceCard(
    BuildContext context,
    Account account,
    NumberFormat currencyFormat,
  ) {
    final isPositive = account.balance >= 0;
    final balanceColor = isPositive ? Colors.green : Colors.red;
    final absBalance = account.balance.abs();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Circular Icon
            Row(
              children: [
                // Balance Circle Indicator
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: balanceColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: balanceColor,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance,
                      color: balanceColor,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Balance Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT BALANCE',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.currency,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(absBalance),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: balanceColor,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Divider line
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            // Account Type and Status
            Row(
              children: [
                // Account Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Type',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.type,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 16),
                // Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: balanceColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPositive ? 'Positive' : 'Negative',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: balanceColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardDisplay(
    BuildContext context,
    WidgetRef ref,
    Account account,
    NumberFormat currencyFormat,
  ) {
    final totalLimit = account.creditLimit ?? 0.0;

    // Calculate utilized limit based on balance and creditLimit
    // Utilized Limit = creditLimit - balance
    // Because: balance decreases when expenses are added, and increases when payment is made
    // Always calculate from balance, not from expenses
    final utilizedLimit = totalLimit > 0
        ? (totalLimit - account.balance).clamp(0.0, totalLimit)
        : 0.0;

    final availableLimit = totalLimit - utilizedLimit;
    final utilizationPercentage = totalLimit > 0
        ? (utilizedLimit / totalLimit * 100).clamp(0.0, 100.0)
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Circular Progress
            Row(
              children: [
                // Arc Progress Indicator (from 6:30 to 4:30, rotated -90 degrees)
                Transform.rotate(
                  angle: -math.pi / 2, // Rotate -90 degrees
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background arc
                        CustomPaint(
                          size: const Size(80, 80),
                          painter: _ArcPainter(
                            progress: 1.0,
                            strokeWidth: 8,
                            color: Colors.grey.shade200,
                            startAngle: -5 * math.pi / 6, // 6:30 o'clock
                            sweepAngle: 5 *
                                math.pi /
                                3, // 300 degrees (from 6:30 to 4:30)
                          ),
                        ),
                        // Progress arc
                        CustomPaint(
                          size: const Size(80, 80),
                          painter: _ArcPainter(
                            progress: utilizationPercentage / 100,
                            strokeWidth: 8,
                            color: Colors.green,
                            startAngle: -5 * math.pi / 6, // 6:30 o'clock
                            sweepAngle: 5 *
                                math.pi /
                                3, // 300 degrees (from 6:30 to 4:30)
                          ),
                        ),
                        // Percentage text (rotated 90 degrees to compensate for arc rotation)
                        Transform.rotate(
                          angle: math.pi /
                              2, // Rotate 90 degrees to keep text upright
                          child: Text(
                            '${utilizationPercentage.toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Utilized Limit Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UTILIZED LIMIT',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.currency,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(utilizedLimit),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Divider line
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            // Total Limit and Available Limit
            Row(
              children: [
                // Total Limit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total limit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${account.currency} ${totalLimit.toInt()}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 16),
                // Available Limit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available limit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${account.currency} ${currencyFormat.format(availableLimit).replaceAll(currencyFormat.currencySymbol, '').trim()}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    WidgetRef ref,
    Account account,
    NumberFormat currencyFormat,
  ) {
    final expensesAsync = ref.watch(expenseListProvider);
    final incomesAsync = ref.watch(incomeListProvider);
    final transfersAsync = ref.watch(transferListProvider);

    return expensesAsync.when(
      data: (allExpenses) {
        return incomesAsync.when(
          data: (allIncomes) {
            return transfersAsync.when(
              data: (allTransfers) {
                // Filter transactions for this account
                final accountExpenses = allExpenses
                    .where((e) => e.accountId == account.id)
                    .toList();
                final accountIncomes =
                    allIncomes.where((i) => i.accountId == account.id).toList();
                final accountTransfers = allTransfers
                    .where(
                      (t) =>
                          t.fromAccountId == account.id ||
                          t.toAccountId == account.id,
                    )
                    .toList();

                // Combine and sort by date (newest first)
                final transactions = <_TransactionItem>[];

                for (final expense in accountExpenses) {
                  transactions.add(
                    _TransactionItem(
                      type: _TransactionType.expense,
                      expense: expense,
                      date: expense.date,
                    ),
                  );
                }

                for (final income in accountIncomes) {
                  transactions.add(
                    _TransactionItem(
                      type: _TransactionType.income,
                      income: income,
                      date: income.date,
                    ),
                  );
                }

                for (final transfer in accountTransfers) {
                  transactions.add(
                    _TransactionItem(
                      type: _TransactionType.transfer,
                      transfer: transfer,
                      date: transfer.date,
                    ),
                  );
                }

                transactions.sort((a, b) => b.date.compareTo(a.date));

                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDesignTokens.space24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Group transactions by date
                final transactionsByDate = <DateTime, List<_TransactionItem>>{};
                for (final transaction in transactions) {
                  final dateKey = DateTime(
                    transaction.date.year,
                    transaction.date.month,
                    transaction.date.day,
                  );
                  if (!transactionsByDate.containsKey(dateKey)) {
                    transactionsByDate[dateKey] = [];
                  }
                  transactionsByDate[dateKey]!.add(transaction);
                }

                // Sort dates (newest first)
                final sortedDates = transactionsByDate.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                // Show only last 10 transactions worth of dates
                final datesToShow = sortedDates.take(10).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...datesToShow.map((date) {
                      final dateTransactions = transactionsByDate[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              DateFormat('EEEE, d MMMM')
                                  .format(date)
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                          // Transactions for this date
                          ...dateTransactions.map((transaction) {
                            return _buildTransactionItem(
                              context,
                              ref,
                              transaction,
                              currencyFormat,
                              account.currency,
                              account,
                            );
                          }),
                        ],
                      );
                    }),
                    if (transactions.length > 10)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: TextButton(
                          onPressed: () {
                            _showAllTransactions(
                              context,
                              ref,
                              transactions,
                              currencyFormat,
                              account.currency,
                              account,
                            );
                          },
                          child: Text(
                            'View all ${transactions.length} transactions',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading transfers: $error'),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading incomes: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading expenses: $error'),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    _TransactionItem transaction,
    NumberFormat currencyFormat,
    String currency,
    Account currentAccount,
  ) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == _TransactionType.expense;
    final isTransfer = transaction.type == _TransactionType.transfer;
    final amount = isExpense
        ? transaction.expense!.amount
        : isTransfer
            ? transaction.transfer!.amount
            : transaction.income!.amount;

    // For transfers, determine if it's incoming or outgoing
    bool isTransferOutgoing = false;
    if (isTransfer) {
      isTransferOutgoing =
          transaction.transfer!.fromAccountId == currentAccount.id;
    }

    final isNegative = isExpense || (isTransfer && isTransferOutgoing);
    final amountColor = isNegative ? AppColors.expense : AppColors.income;
    final sign = isNegative ? '-' : '+';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isNegative
                  ? AppColors.expense.withValues(alpha: 0.1)
                  : AppColors.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense
                  ? Icons.shopping_bag_outlined
                  : isTransfer
                      ? Icons.swap_horiz_rounded
                      : Icons.attach_money_rounded,
              color: isNegative ? AppColors.expense : AppColors.income,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpense)
                  Consumer(
                    builder: (context, ref, _) {
                      final categoriesAsync = ref.watch(categoriesProvider);
                      return categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) {
                            return Text(
                              'Expense',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          final category = categories.firstWhere(
                            (c) => c.id == transaction.expense!.categoryId,
                            orElse: () => categories.first,
                          );
                          return Text(
                            category.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const Text('Expense'),
                      );
                    },
                  )
                else if (isTransfer)
                  Consumer(
                    builder: (context, ref, _) {
                      final accountsAsync = ref.watch(accountListProvider);
                      return accountsAsync.when(
                        data: (accounts) {
                          final otherAccountId = isTransferOutgoing
                              ? transaction.transfer!.toAccountId
                              : transaction.transfer!.fromAccountId;
                          final otherAccount = accounts.firstWhere(
                            (a) => a.id == otherAccountId,
                            orElse: () => currentAccount,
                          );
                          return Text(
                            '${isTransferOutgoing ? 'To' : 'From'} ${otherAccount.name}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const Text('Transfer'),
                      );
                    },
                  )
                else
                  Text(
                    transaction.income!.source,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                // Note or Date/Time fallback
                Text(
                  _getTransactionNote(transaction) ??
                      DateFormat.jm().format(transaction.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount
          Text(
            '$sign${currencyFormat.format(amount).replaceAll(currencyFormat.currencySymbol, '').trim()}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String? _getTransactionNote(_TransactionItem transaction) {
    switch (transaction.type) {
      case _TransactionType.expense:
        return transaction.expense?.note?.isNotEmpty == true
            ? transaction.expense!.note
            : null;
      case _TransactionType.income:
        return transaction.income?.note?.isNotEmpty == true
            ? transaction.income!.note
            : null;
      case _TransactionType.transfer:
        return transaction.transfer?.note?.isNotEmpty == true
            ? transaction.transfer!.note
            : null;
    }
  }

  void _showAllTransactions(
    BuildContext context,
    WidgetRef ref,
    List<_TransactionItem> transactions,
    NumberFormat currencyFormat,
    String currency,
    Account account,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Group transactions by date
        final transactionsByDate = <DateTime, List<_TransactionItem>>{};
        for (final transaction in transactions) {
          final dateKey = DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          );
          if (!transactionsByDate.containsKey(dateKey)) {
            transactionsByDate[dateKey] = [];
          }
          transactionsByDate[dateKey]!.add(transaction);
        }

        final sortedDates = transactionsByDate.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${transactions.length} transactions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                // Transaction list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final dateTransactions = transactionsByDate[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              DateFormat('EEEE, d MMMM')
                                  .format(date)
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                          // Transactions
                          ...dateTransactions.map(
                            (transaction) => _buildTransactionItem(
                              context,
                              ref,
                              transaction,
                              currencyFormat,
                              currency,
                              account,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Helper class for transactions
enum _TransactionType { expense, income, transfer }

class _TransactionItem {
  final _TransactionType type;
  final Expense? expense;
  final Income? income;
  final Transfer? transfer;
  final DateTime date;

  _TransactionItem({
    required this.type,
    this.expense,
    this.income,
    this.transfer,
    required this.date,
  });
}

// Custom Painter for Arc Progress Indicator
class _ArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;
  final double sweepAngle;

  _ArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Calculate the actual sweep angle based on progress
    final actualSweepAngle = sweepAngle * progress;

    // Draw the arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      actualSweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
