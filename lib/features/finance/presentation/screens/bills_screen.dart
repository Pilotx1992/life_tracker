import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_bill_dialog.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/widgets/bill_list_item.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/error_widget.dart' as error_widget;
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';

/// Bill filter options
enum BillFilterType { all, overdue, dueToday, upcoming, inactive }

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  BillFilterType _selectedFilter = BillFilterType.all;
  String? _selectedFrequency; // 'Monthly', 'Weekly', 'Yearly'

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Bills'),
        actions: [
          // Filter button with active indicator
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context),
                tooltip: 'Filter Bills',
              ),
              if (_selectedFilter != BillFilterType.all ||
                  _selectedFrequency != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Filter Chips
          _buildQuickFilterChips(),

          // Bills List
          Expanded(
            child: billsAsync.when(
              data: (bills) {
                final filteredBills = _applyFilters(bills);

                if (filteredBills.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(billNotifierProvider.notifier).loadBills(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: EmptyStateWidget(
                          icon: Icons.receipt_long,
                          title: _hasActiveFilters
                              ? 'No bills match your filters'
                              : 'No Recurring Bills',
                          subtitle: _hasActiveFilters
                              ? null
                              : 'Add your first recurring bill to start tracking',
                          actionLabel:
                              _hasActiveFilters ? 'Clear Filters' : null,
                          onAction: _hasActiveFilters ? _clearAllFilters : null,
                        ),
                      ),
                    ),
                  );
                }

                // Separate bills into categories
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final overdueBills = filteredBills
                    .where((b) => b.isActive && b.nextDueDate.isBefore(today))
                    .toList();
                final dueTodayBills = filteredBills
                    .where((b) =>
                        b.isActive &&
                        DateTime(
                              b.nextDueDate.year,
                              b.nextDueDate.month,
                              b.nextDueDate.day,
                            ) ==
                            today,)
                    .toList();
                final upcomingBills = filteredBills
                    .where((b) => b.isActive && b.nextDueDate.isAfter(today))
                    .toList();
                final inactiveBills =
                    filteredBills.where((b) => !b.isActive).toList();

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(billNotifierProvider.notifier).loadBills(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary Card
                      _buildSummaryCard(context, bills),
                      const SizedBox(height: 16),

                      // Active Filters Display
                      if (_hasActiveFilters) ...[
                        _buildActiveFiltersChips(),
                        const SizedBox(height: 16),
                      ],

                      // Overdue Section
                      if (overdueBills.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Overdue',
                          overdueBills.length,
                          Colors.red,
                        ),
                        const SizedBox(height: 8),
                        ...overdueBills
                            .map((bill) => _buildBillItem(context, bill)),
                        const SizedBox(height: 16),
                      ],

                      // Due Today Section
                      if (dueTodayBills.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Due Today',
                          dueTodayBills.length,
                          Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        ...dueTodayBills
                            .map((bill) => _buildBillItem(context, bill)),
                        const SizedBox(height: 16),
                      ],

                      // Upcoming Section
                      if (upcomingBills.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Upcoming',
                          upcomingBills.length,
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        ...upcomingBills
                            .map((bill) => _buildBillItem(context, bill)),
                        const SizedBox(height: 16),
                      ],

                      // Inactive Section
                      if (inactiveBills.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Inactive',
                          inactiveBills.length,
                          Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        ...inactiveBills
                            .map((bill) => _buildBillItem(context, bill)),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(useShimmer: true),
              error: (error, stack) =>
                  error_widget.ErrorDisplayWidget(message: error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBillDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedFilter != BillFilterType.all || _selectedFrequency != null;

  Widget _buildQuickFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Status filter chips
            FilterChip(
              label: const Text('All'),
              selected: _selectedFilter == BillFilterType.all,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = BillFilterType.all);
                }
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.warning, size: 18, color: Colors.red),
              label: const Text('Overdue'),
              selected: _selectedFilter == BillFilterType.overdue,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter =
                      selected ? BillFilterType.overdue : BillFilterType.all;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.today, size: 18, color: Colors.orange),
              label: const Text('Due Today'),
              selected: _selectedFilter == BillFilterType.dueToday,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter =
                      selected ? BillFilterType.dueToday : BillFilterType.all;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.schedule, size: 18, color: Colors.blue),
              label: const Text('Upcoming'),
              selected: _selectedFilter == BillFilterType.upcoming,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter =
                      selected ? BillFilterType.upcoming : BillFilterType.all;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.pause, size: 18, color: Colors.grey),
              label: const Text('Inactive'),
              selected: _selectedFilter == BillFilterType.inactive,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter =
                      selected ? BillFilterType.inactive : BillFilterType.all;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];

    if (_selectedFilter != BillFilterType.all) {
      chips.add(
        Chip(
          label: Text(_getFilterLabel(_selectedFilter)),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() => _selectedFilter = BillFilterType.all);
          },
        ),
      );
    }

    if (_selectedFrequency != null) {
      chips.add(
        Chip(
          label: Text(_selectedFrequency!),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() => _selectedFrequency = null);
          },
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips,
    );
  }

  String _getFilterLabel(BillFilterType filter) {
    switch (filter) {
      case BillFilterType.all:
        return 'All';
      case BillFilterType.overdue:
        return 'Overdue';
      case BillFilterType.dueToday:
        return 'Due Today';
      case BillFilterType.upcoming:
        return 'Upcoming';
      case BillFilterType.inactive:
        return 'Inactive';
    }
  }

  List<RecurringBill> _applyFilters(List<RecurringBill> bills) {
    var filtered = bills;

    // Apply frequency filter
    if (_selectedFrequency != null) {
      filtered = filtered
          .where((b) =>
              b.frequency.toLowerCase() == _selectedFrequency!.toLowerCase(),)
          .toList();
    }

    // Apply status filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case BillFilterType.all:
        break;
      case BillFilterType.overdue:
        filtered = filtered
            .where((b) => b.isActive && b.nextDueDate.isBefore(today))
            .toList();
        break;
      case BillFilterType.dueToday:
        filtered = filtered
            .where((b) =>
                b.isActive &&
                DateTime(
                      b.nextDueDate.year,
                      b.nextDueDate.month,
                      b.nextDueDate.day,
                    ) ==
                    today,)
            .toList();
        break;
      case BillFilterType.upcoming:
        filtered = filtered
            .where((b) => b.isActive && b.nextDueDate.isAfter(today))
            .toList();
        break;
      case BillFilterType.inactive:
        filtered = filtered.where((b) => !b.isActive).toList();
        break;
    }

    return filtered;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilter = BillFilterType.all;
      _selectedFrequency = null;
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Bills',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      _clearAllFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Frequency Filter
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFrequency == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFrequency = null);
                      Navigator.pop(context);
                    }
                  },
                ),
                FilterChip(
                  avatar: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Monthly'),
                  selected: _selectedFrequency == 'Monthly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFrequency = selected ? 'Monthly' : null;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: const Text('Weekly'),
                  selected: _selectedFrequency == 'Weekly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFrequency = selected ? 'Weekly' : null;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Yearly'),
                  selected: _selectedFrequency == 'Yearly',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFrequency = selected ? 'Yearly' : null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(BuildContext context, RecurringBill bill) {
    return Dismissible(
      key: Key('bill_${bill.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
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
                title: const Text('Delete Bill'),
                content: Text(
                  'Are you sure you want to delete ${bill.name}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        if (bill.id != null) {
          ref.read(billNotifierProvider.notifier).deleteBillEntry(bill.id!);
          FeedbackService.showSuccess(context, '${bill.name} deleted');
        }
      },
      child: BillListItem(bill: bill),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<RecurringBill> bills) {
    final activeBills = bills.where((b) => b.isActive).toList();
    final totalMonthly = activeBills.fold<double>(
      0.0,
      (sum, bill) {
        if (bill.frequency.toLowerCase() == 'monthly') {
          return sum + bill.amount;
        } else if (bill.frequency.toLowerCase() == 'weekly') {
          return sum + (bill.amount * 4.33);
        } else if (bill.frequency.toLowerCase() == 'yearly') {
          return sum + (bill.amount / 12);
        }
        return sum;
      },
    );

    // Count by status
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final overdueCount =
        activeBills.where((b) => b.nextDueDate.isBefore(today)).length;

    return Container(
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
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
                'Bills Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (overdueCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$overdueCount Overdue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                context,
                'Active Bills',
                activeBills.length.toString(),
                Icons.receipt_long,
              ),
              _buildSummaryItem(
                context,
                'Est. Monthly',
                NumberFormat.currency(symbol: 'E£').format(totalMonthly),
                Icons.calendar_month,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  void _showAddBillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBillDialog(),
    );
  }
}
