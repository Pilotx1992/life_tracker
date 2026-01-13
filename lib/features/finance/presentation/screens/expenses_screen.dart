import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/expense_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/category_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:life_tracker/features/finance/presentation/widgets/expense_list_item.dart';
import 'package:life_tracker/features/finance/presentation/widgets/expense_summary_card.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';
import 'package:life_tracker/shared/widgets/filters/enhanced_filter_bottom_sheet.dart';
import 'package:life_tracker/features/finance/presentation/widgets/expense_detail_bottom_sheet.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  FilterResult _currentFilter = FilterResult.empty();

  @override
  Widget build(BuildContext context) {
    final expenseListAsyncValue = ref.watch(expenseListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountListProvider);

    // Filter expenses based on current filter
    final filteredExpenses = expenseListAsyncValue.whenData((expenses) {
      return _applyFilters(expenses);
    });

    // Calculate total expenses
    double totalAmount = 0;
    int expenseCount = 0;
    filteredExpenses.whenData((expenses) {
      totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
      expenseCount = expenses.length;
    });

    // Get default currency (first expense or EGP)
    String currency = 'EGP';
    filteredExpenses.whenData((expenses) {
      if (expenses.isNotEmpty) {
        currency = expenses.first.currency;
      }
    });

    // Build category and account filter options
    List<CategoryFilterOption> categoryOptions = [];
    categoriesAsync.whenData((categories) {
      categoryOptions = categories
          .map((c) => CategoryFilterOption(
                id: c.id ?? 0,
                name: c.name,
                // Note: Category entity stores icon as String, so we skip it for filter options
              ),)
          .toList();
    });

    List<AccountFilterOption> accountOptions = [];
    accountsAsync.whenData((accounts) {
      accountOptions = accounts
          .map((a) => AccountFilterOption(
                id: a.id ?? 0,
                name: a.name,
                type: a.type,
              ),)
          .toList();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          // Filter badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showEnhancedFilterSheet(
                  context,
                  categoryOptions,
                  accountOptions,
                ),
                tooltip: 'Filter Expenses',
              ),
              if (_currentFilter.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_currentFilter.activeFilterCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Filter Bar
          QuickFilterBar(
            currentFilter: _currentFilter,
            categories: categoryOptions,
            accounts: accountOptions,
            onFilterTap: () => _showEnhancedFilterSheet(
              context,
              categoryOptions,
              accountOptions,
            ),
            onQuickFilterChanged: (filter) {
              setState(() => _currentFilter = filter);
              _applyFilterToProvider();
            },
          ),

          // Active Filters Display
          if (_currentFilter.hasActiveFilters)
            _buildActiveFiltersChips(categoryOptions, accountOptions),

          // Summary Card
          if (expenseCount > 0)
            ExpenseSummaryCard(
              totalAmount: totalAmount,
              currency: currency,
              expenseCount: expenseCount,
              periodStart: _currentFilter.startDate,
              periodEnd: _currentFilter.endDate,
            ),

          // Expenses List
          Expanded(
            child: filteredExpenses.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(expenseNotifierProvider.notifier)
                          .loadExpenses();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: EmptyStateWidget(
                          icon: Icons.receipt_long,
                          title: _currentFilter.hasActiveFilters
                              ? 'No expenses match your filters'
                              : 'No expenses yet. Add your first expense!',
                          actionLabel: _currentFilter.hasActiveFilters
                              ? 'Clear Filters'
                              : null,
                          onAction: _currentFilter.hasActiveFilters
                              ? () {
                                  setState(() {
                                    _currentFilter = FilterResult.empty();
                                  });
                                  _applyFilterToProvider();
                                }
                              : null,
                        ),
                      ),
                    ),
                  );
                }

                return categoriesAsync.when(
                  data: (categories) {
                    return accountsAsync.when(
                      data: (accounts) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(expenseNotifierProvider.notifier)
                                .loadExpenses();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 88), // Space for FAB
                            physics: const AlwaysScrollableScrollPhysics(),
                            cacheExtent: 500,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              final category = categories.firstWhere(
                                (c) => c.id == expense.categoryId,
                                orElse: () => categories.first,
                              );
                              final account = accounts
                                  .where((a) => a.id == expense.accountId)
                                  .firstOrNull;

                              return Dismissible(
                                key: ValueKey('expense_${expense.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: AlignmentDirectional.centerEnd,
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                    size: 32,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Expense'),
                                          content: const Text(
                                            'Are you sure you want to delete this expense?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                },
                                onDismissed: (direction) async {
                                  await _deleteExpense(context, expense);
                                },
                                child: ExpenseListItem(
                                  expense: expense,
                                  category: category,
                                  account: account,
                                  onTap: () => ExpenseDetailBottomSheet.show(
                                    context,
                                    expense: expense,
                                    category: category,
                                    account: account,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => SkeletonList.cards(itemCount: 8),
                      error: (error, stack) =>
                          ErrorStateWidget(message: error.toString()),
                    );
                  },
                  loading: () => SkeletonList.cards(itemCount: 8),
                  error: (error, stack) =>
                      ErrorStateWidget(message: error.toString()),
                );
              },
              loading: () => SkeletonList.cards(itemCount: 8),
              error: (error, stack) =>
                  ErrorStateWidget(message: error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveFiltersChips(
    List<CategoryFilterOption> categories,
    List<AccountFilterOption> accounts,
  ) {
    final chips = <Widget>[];

    // Date filter chip
    if (_currentFilter.startDate != null) {
      final dateFormat = DateFormat('MMM dd');
      chips.add(
        Chip(
          label: Text(
            _currentFilter.datePreset != null &&
                    _currentFilter.datePreset != 'custom'
                ? _getDatePresetLabel(_currentFilter.datePreset!)
                : '${dateFormat.format(_currentFilter.startDate!)} - ${dateFormat.format(_currentFilter.endDate!)}',
          ),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _currentFilter = _currentFilter.copyWith(clearDates: true);
            });
            _applyFilterToProvider();
          },
        ),
      );
    }

    // Category filter chip
    if (_currentFilter.categoryId != null) {
      final category = categories.firstWhere(
        (c) => c.id == _currentFilter.categoryId,
        orElse: () => const CategoryFilterOption(id: 0, name: 'Unknown'),
      );
      chips.add(
        Chip(
          label: Text(category.name),
          avatar: category.icon != null ? Icon(category.icon, size: 16) : null,
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _currentFilter = _currentFilter.copyWith(clearCategory: true);
            });
            _applyFilterToProvider();
          },
        ),
      );
    }

    // Account filter chip
    if (_currentFilter.accountId != null) {
      final account = accounts.firstWhere(
        (a) => a.id == _currentFilter.accountId,
        orElse: () => const AccountFilterOption(id: 0, name: 'Unknown'),
      );
      chips.add(
        Chip(
          label: Text(account.name),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _currentFilter = _currentFilter.copyWith(clearAccount: true);
            });
            _applyFilterToProvider();
          },
        ),
      );
    }

    // Amount filter chip
    if (_currentFilter.minAmount != null || _currentFilter.maxAmount != null) {
      final amountText =
          _currentFilter.minAmount != null && _currentFilter.maxAmount != null
              ? 'E£${_currentFilter.minAmount} - E£${_currentFilter.maxAmount}'
              : _currentFilter.minAmount != null
                  ? 'Min E£${_currentFilter.minAmount}'
                  : 'Max E£${_currentFilter.maxAmount}';
      chips.add(
        Chip(
          label: Text(amountText),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _currentFilter = _currentFilter.copyWith(clearAmount: true);
            });
            _applyFilterToProvider();
          },
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: chips,
      ),
    );
  }

  String _getDatePresetLabel(String preset) {
    switch (preset) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return 'Custom';
    }
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    var filtered = expenses;

    // Date filter
    if (_currentFilter.startDate != null && _currentFilter.endDate != null) {
      filtered = filtered.where((e) {
        return e.date.isAfter(
                _currentFilter.startDate!.subtract(const Duration(days: 1)),) &&
            e.date
                .isBefore(_currentFilter.endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Category filter
    if (_currentFilter.categoryId != null) {
      filtered = filtered
          .where((e) => e.categoryId == _currentFilter.categoryId)
          .toList();
    }

    // Account filter
    if (_currentFilter.accountId != null) {
      filtered = filtered
          .where((e) => e.accountId == _currentFilter.accountId)
          .toList();
    }

    // Amount filter
    if (_currentFilter.minAmount != null) {
      filtered =
          filtered.where((e) => e.amount >= _currentFilter.minAmount!).toList();
    }
    if (_currentFilter.maxAmount != null) {
      filtered =
          filtered.where((e) => e.amount <= _currentFilter.maxAmount!).toList();
    }

    return filtered;
  }

  void _applyFilterToProvider() {
    // Reload from database when clearing filters
    if (!_currentFilter.hasActiveFilters) {
      ref.read(expenseNotifierProvider.notifier).loadExpenses();
    } else if (_currentFilter.startDate != null &&
        _currentFilter.endDate != null) {
      ref.read(expenseNotifierProvider.notifier).loadExpensesByDateRange(
            _currentFilter.startDate!,
            _currentFilter.endDate!,
          );
    }
  }

  void _showEnhancedFilterSheet(
    BuildContext context,
    List<CategoryFilterOption> categories,
    List<AccountFilterOption> accounts,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => EnhancedFilterBottomSheet(
          title: 'Filter Expenses',
          currentFilter: _currentFilter,
          categories: categories,
          accounts: accounts,
          showDateFilter: true,
          showCategoryFilter: true,
          showAccountFilter: true,
          showAmountFilter: true,
          onApply: (filter) {
            setState(() => _currentFilter = filter);
            _applyFilterToProvider();
          },
        ),
      ),
    );
  }

  void _showAddExpenseBottomSheet(BuildContext context) {
    final accountsAsync = ref.read(accountListProvider);

    accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Accounts Available'),
              content: const Text(
                'You need to create at least one account before adding expenses. '
                'Would you like to go to the Accounts screen?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.financeAccounts);
                  },
                  child: const Text('Go to Accounts'),
                ),
              ],
            ),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddExpenseBottomSheet(),
          );
        }
      },
      loading: () {
        FeedbackService.showInfo(context, 'Loading accounts...');
      },
      error: (error, stack) {
        FeedbackService.showError(context, 'Error loading accounts: $error');
      },
    );
  }

  Future<void> _deleteExpense(BuildContext context, Expense expense) async {
    if (expense.id == null) return;

    await ref
        .read(expenseNotifierProvider.notifier)
        .deleteExpenseEntry(expense.id!);
    await _updateAccountBalance(ref, expense.accountId, expense.amount);
    if (!context.mounted) return;
    FeedbackService.showSuccess(context, 'Expense deleted');
  }

  Future<void> _updateAccountBalance(
    WidgetRef ref,
    int accountId,
    double amountChange,
  ) async {
    final accountsAsync = ref.read(accountListProvider);
    accountsAsync.whenData((accounts) {
      final account = accounts.firstWhere(
        (a) => a.id == accountId,
        orElse: () => accounts.first,
      );

      if (account.id != null) {
        final updatedAccount = account.copyWith(
          balance: account.balance + amountChange,
        );
        ref
            .read(accountNotifierProvider.notifier)
            .updateAccountEntry(updatedAccount);
      }
    });
  }
}
