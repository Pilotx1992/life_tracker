import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/expense_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/income_provider.dart';

class FinanceSummaryCard extends ConsumerWidget {
  const FinanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final expensesAsync = ref.watch(expenseNotifierProvider);
    final incomesAsync = ref.watch(incomeNotifierProvider);
    final billsAsync = ref.watch(billNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Finance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppRoutes.finance),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Total Balance
            accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No accounts',
                    'Add an account to get started',
                    () => context.push(AppRoutes.finance),
                  );
                }
                return FutureBuilder<double?>(
                  future: ref
                      .read(accountNotifierProvider.notifier)
                      .getTotalBalance(),
                  builder: (context, snapshot) {
                    final totalBalance = snapshot.data ?? 0.0;
                    final primaryCurrency =
                        accounts.isNotEmpty ? accounts.first.currency : 'USD';
                    return _buildBalanceInfo(
                      context,
                      totalBalance,
                      primaryCurrency,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Monthly Summary
            Row(
              children: [
                Expanded(
                  child: expensesAsync.when(
                    data: (expenses) {
                      final now = DateTime.now();
                      final monthStart = DateTime(now.year, now.month, 1);
                      final monthExpenses = expenses
                          .where(
                            (e) =>
                                e.date.isAfter(monthStart) ||
                                e.date.isAtSameMomentAs(monthStart),
                          )
                          .fold<double>(0.0, (sum, e) => sum + e.amount);
                      return _buildStatItem(
                        context,
                        'Expenses',
                        monthExpenses,
                        Colors.red,
                        Icons.trending_down,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: incomesAsync.when(
                    data: (incomes) {
                      final now = DateTime.now();
                      final monthStart = DateTime(now.year, now.month, 1);
                      final monthIncomes = incomes
                          .where(
                            (e) =>
                                e.date.isAfter(monthStart) ||
                                e.date.isAtSameMomentAs(monthStart),
                          )
                          .fold<double>(0.0, (sum, e) => sum + e.amount);
                      return _buildStatItem(
                        context,
                        'Income',
                        monthIncomes,
                        Colors.green,
                        Icons.trending_up,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Upcoming Bills
            billsAsync.when(
              data: (bills) {
                final activeBills = bills.where((b) => b.isActive).toList();
                if (activeBills.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No upcoming bills',
                    'Add recurring bills to track',
                    () => context.push(AppRoutes.finance),
                  );
                }
                final upcomingBills = activeBills
                    .where(
                      (b) =>
                          b.nextDueDate.isAfter(DateTime.now()) ||
                          b.nextDueDate.isAtSameMomentAs(DateTime.now()),
                    )
                    .toList();
                upcomingBills
                    .sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
                return _buildUpcomingBills(
                  context,
                  upcomingBills.take(3).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
            const SizedBox(height: 16),
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.finance),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.finance),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Income'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(
    BuildContext context,
    double balance,
    String currency,
  ) {
    final formatter =
        NumberFormat.currency(symbol: _getCurrencySymbol(currency));
    return Row(
      children: [
        const Icon(Icons.account_balance, size: 32, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                formatter.format(balance),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(value),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBills(BuildContext context, List<RecurringBill> bills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Bills',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...bills.map(
          (bill) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.receipt, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(bill.amount)} - ${DateFormat('MMM dd').format(bill.nextDueDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Error: $error',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return 'ر.س';
      case 'EGP':
        return 'E£';
      default:
        return currency;
    }
  }
}
