import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/income_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_income_dialog.dart';
import 'package:life_tracker/features/finance/presentation/widgets/income_list_item.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';
import 'package:life_tracker/shared/widgets/filters/enhanced_filter_bottom_sheet.dart';

class IncomesScreen extends ConsumerStatefulWidget {
  const IncomesScreen({super.key});

  @override
  ConsumerState<IncomesScreen> createState() => _IncomesScreenState();
}

class _IncomesScreenState extends ConsumerState<IncomesScreen> {
  FilterResult _currentFilter = FilterResult.empty();

  @override
  Widget build(BuildContext context) {
    final incomeListAsyncValue = ref.watch(incomeListProvider);
    final accountsAsync = ref.watch(accountListProvider);

    // Filter incomes based on current filter
    final filteredIncomes = incomeListAsyncValue.whenData((incomes) {
      return _applyFilters(incomes);
    });

    // Calculate total income
    double totalAmount = 0;
    int incomeCount = 0;
    filteredIncomes.whenData((incomes) {
      totalAmount = incomes.fold(0.0, (sum, i) => sum + i.amount);
      incomeCount = incomes.length;
    });

    // Get default currency
    String currency = 'EGP';
    filteredIncomes.whenData((incomes) {
      if (incomes.isNotEmpty) {
        currency = incomes.first.currency;
      }
    });

    // Build account filter options
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
        title: const Text('Income'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () =>
                    _showEnhancedFilterSheet(context, accountOptions),
                tooltip: 'Filter Income',
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
            accounts: accountOptions,
            onFilterTap: () =>
                _showEnhancedFilterSheet(context, accountOptions),
            onQuickFilterChanged: (filter) {
              setState(() => _currentFilter = filter);
              _applyFilterToProvider();
            },
          ),

          // Active Filters Display
          if (_currentFilter.hasActiveFilters)
            _buildActiveFiltersChips(accountOptions),

          // Summary Card
          if (incomeCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Income',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _currentFilter.startDate != null
                            ? '${DateFormat('MMM dd').format(_currentFilter.startDate!)} - ${DateFormat('MMM dd').format(_currentFilter.endDate!)}'
                            : 'All Time',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    NumberFormat.currency(symbol: _getCurrencySymbol(currency))
                        .format(totalAmount),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50), // Green color for income
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$incomeCount ${incomeCount == 1 ? 'income' : 'incomes'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Incomes List
          Expanded(
            child: filteredIncomes.when(
              data: (incomes) {
                if (incomes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(incomeNotifierProvider.notifier)
                          .loadIncomes();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: EmptyStateWidget(
                          icon: Icons.account_balance_wallet,
                          title: _currentFilter.hasActiveFilters
                              ? 'No income matches your filters'
                              : 'No income recorded yet. Add your first income!',
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

                return accountsAsync.when(
                  data: (accounts) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(incomeNotifierProvider.notifier)
                            .loadIncomes();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 88), // Space for FAB
                        physics: const AlwaysScrollableScrollPhysics(),
                        cacheExtent: 500,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemCount: incomes.length,
                        itemBuilder: (context, index) {
                          final income = incomes[index];
                          final account = accounts
                              .where((a) => a.id == income.accountId)
                              .firstOrNull;
                          return Dismissible(
                            key: ValueKey('income_${income.id}'),
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
                                color: Theme.of(context).colorScheme.onError,
                                size: 32,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Income'),
                                      content: const Text(
                                        'Are you sure you want to delete this income?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
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
                              await _deleteIncome(context, income);
                            },
                            child: IncomeListItem(
                              income: income,
                              account: account,
                              onTap: () =>
                                  _showEditIncomeDialog(context, income),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const LoadingWidget(useShimmer: true),
                  error: (error, stack) =>
                      ErrorStateWidget(message: error.toString()),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) =>
                  ErrorStateWidget(message: error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveFiltersChips(List<AccountFilterOption> accounts) {
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

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'EGP':
        return 'E£';
      default:
        return currency;
    }
  }

  List<Income> _applyFilters(List<Income> incomes) {
    var filtered = incomes;

    // Date filter
    if (_currentFilter.startDate != null && _currentFilter.endDate != null) {
      filtered = filtered.where((i) {
        return i.date.isAfter(
                _currentFilter.startDate!.subtract(const Duration(days: 1)),) &&
            i.date
                .isBefore(_currentFilter.endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Account filter
    if (_currentFilter.accountId != null) {
      filtered = filtered
          .where((i) => i.accountId == _currentFilter.accountId)
          .toList();
    }

    // Amount filter
    if (_currentFilter.minAmount != null) {
      filtered =
          filtered.where((i) => i.amount >= _currentFilter.minAmount!).toList();
    }
    if (_currentFilter.maxAmount != null) {
      filtered =
          filtered.where((i) => i.amount <= _currentFilter.maxAmount!).toList();
    }

    return filtered;
  }

  void _applyFilterToProvider() {
    if (!_currentFilter.hasActiveFilters) {
      ref.read(incomeNotifierProvider.notifier).loadIncomes();
    } else if (_currentFilter.startDate != null &&
        _currentFilter.endDate != null) {
      ref.read(incomeNotifierProvider.notifier).loadIncomesByDateRange(
            _currentFilter.startDate!,
            _currentFilter.endDate!,
          );
    }
  }

  void _showEnhancedFilterSheet(
    BuildContext context,
    List<AccountFilterOption> accounts,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => EnhancedFilterBottomSheet(
          title: 'Filter Income',
          currentFilter: _currentFilter,
          accounts: accounts,
          showDateFilter: true,
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

  void _showAddIncomeDialog(BuildContext context) {
    final accountsAsync = ref.read(accountListProvider);

    accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Accounts Available'),
              content: const Text(
                'You need to create at least one account before adding income. '
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
          showDialog(
            context: context,
            builder: (context) => const AddIncomeDialog(),
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

  void _showEditIncomeDialog(BuildContext context, Income income) {
    showDialog(
      context: context,
      builder: (context) => AddIncomeDialog(income: income),
    );
  }

  Future<void> _deleteIncome(BuildContext context, Income income) async {
    if (income.id == null) return;

    await ref
        .read(incomeNotifierProvider.notifier)
        .deleteIncomeEntry(income.id!);
    await _updateAccountBalance(ref, income.accountId, -income.amount);
    if (context.mounted) {
      FeedbackService.showSuccess(context, 'Income deleted');
    }
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
