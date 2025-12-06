import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// Filter result containing all selected filter options
class FilterResult {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? datePreset; // 'today', 'week', 'month', 'year', 'custom'
  final int? categoryId;
  final int? accountId;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  final Map<String, dynamic>? customFilters;

  const FilterResult({
    this.startDate,
    this.endDate,
    this.datePreset,
    this.categoryId,
    this.accountId,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.customFilters,
  });

  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      categoryId != null ||
      accountId != null ||
      minAmount != null ||
      maxAmount != null ||
      searchQuery != null ||
      (customFilters != null && customFilters!.isNotEmpty);

  int get activeFilterCount {
    int count = 0;
    if (startDate != null || endDate != null) count++;
    if (categoryId != null) count++;
    if (accountId != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    return count;
  }

  FilterResult copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? datePreset,
    int? categoryId,
    int? accountId,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    Map<String, dynamic>? customFilters,
    bool clearDates = false,
    bool clearCategory = false,
    bool clearAccount = false,
    bool clearAmount = false,
  }) {
    return FilterResult(
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      datePreset: clearDates ? null : (datePreset ?? this.datePreset),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      minAmount: clearAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmount ? null : (maxAmount ?? this.maxAmount),
      searchQuery: searchQuery ?? this.searchQuery,
      customFilters: customFilters ?? this.customFilters,
    );
  }

  static FilterResult empty() => const FilterResult();
}

/// Quick filter chip data
class QuickFilterOption {
  final String id;
  final String label;
  final IconData? icon;
  final DateTime Function()? getStartDate;
  final DateTime Function()? getEndDate;

  const QuickFilterOption({
    required this.id,
    required this.label,
    this.icon,
    this.getStartDate,
    this.getEndDate,
  });

  static List<QuickFilterOption> datePresets = [
    QuickFilterOption(
      id: 'today',
      label: 'Today',
      icon: Icons.today,
      getStartDate: () => DateTime.now(),
      getEndDate: () => DateTime.now(),
    ),
    QuickFilterOption(
      id: 'week',
      label: 'This Week',
      icon: Icons.date_range,
      getStartDate: () {
        final now = DateTime.now();
        return now.subtract(Duration(days: now.weekday - 1));
      },
      getEndDate: () => DateTime.now(),
    ),
    QuickFilterOption(
      id: 'month',
      label: 'This Month',
      icon: Icons.calendar_month,
      getStartDate: () {
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      },
      getEndDate: () => DateTime.now(),
    ),
    QuickFilterOption(
      id: 'year',
      label: 'This Year',
      icon: Icons.calendar_today,
      getStartDate: () => DateTime(DateTime.now().year, 1, 1),
      getEndDate: () => DateTime.now(),
    ),
  ];
}

/// Category filter option
class CategoryFilterOption {
  final int id;
  final String name;
  final IconData? icon;
  final Color? color;

  const CategoryFilterOption({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });
}

/// Account filter option
class AccountFilterOption {
  final int id;
  final String name;
  final String? type;

  const AccountFilterOption({
    required this.id,
    required this.name,
    this.type,
  });
}

/// Enhanced Filter Bottom Sheet widget
class EnhancedFilterBottomSheet extends StatefulWidget {
  final String title;
  final FilterResult currentFilter;
  final List<CategoryFilterOption>? categories;
  final List<AccountFilterOption>? accounts;
  final bool showDateFilter;
  final bool showCategoryFilter;
  final bool showAccountFilter;
  final bool showAmountFilter;
  final bool showSearchFilter;
  final List<Widget>? customFilterWidgets;
  final ValueChanged<FilterResult> onApply;

  const EnhancedFilterBottomSheet({
    super.key,
    required this.title,
    required this.currentFilter,
    this.categories,
    this.accounts,
    this.showDateFilter = true,
    this.showCategoryFilter = false,
    this.showAccountFilter = false,
    this.showAmountFilter = false,
    this.showSearchFilter = false,
    this.customFilterWidgets,
    required this.onApply,
  });

  @override
  State<EnhancedFilterBottomSheet> createState() =>
      _EnhancedFilterBottomSheetState();
}

class _EnhancedFilterBottomSheetState extends State<EnhancedFilterBottomSheet> {
  late FilterResult _filter;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _minAmountController.text = _filter.minAmount?.toString() ?? '';
    _maxAmountController.text = _filter.maxAmount?.toString() ?? '';
    _searchController.text = _filter.searchQuery ?? '';
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppDesignTokens.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_filter.hasActiveFilters)
                      TextButton(
                        onPressed: _clearAllFilters,
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        widget.onApply(_filter);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search filter
                  if (widget.showSearchFilter) ...[
                    _buildSectionTitle('Search'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _filter = _filter.copyWith(searchQuery: '');
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value);
                        });
                      },
                    ),
                    const SizedBox(height: AppDesignTokens.space20),
                  ],

                  // Date filter
                  if (widget.showDateFilter) ...[
                    _buildSectionTitle('Date Range'),
                    const SizedBox(height: 12),
                    _buildQuickDateChips(),
                    const SizedBox(height: 12),
                    _buildCustomDateRange(),
                    const SizedBox(height: AppDesignTokens.space20),
                  ],

                  // Category filter
                  if (widget.showCategoryFilter &&
                      widget.categories != null &&
                      widget.categories!.isNotEmpty) ...[
                    _buildSectionTitle('Category'),
                    const SizedBox(height: 12),
                    _buildCategoryChips(),
                    const SizedBox(height: AppDesignTokens.space20),
                  ],

                  // Account filter
                  if (widget.showAccountFilter &&
                      widget.accounts != null &&
                      widget.accounts!.isNotEmpty) ...[
                    _buildSectionTitle('Account'),
                    const SizedBox(height: 12),
                    _buildAccountChips(),
                    const SizedBox(height: AppDesignTokens.space20),
                  ],

                  // Amount filter
                  if (widget.showAmountFilter) ...[
                    _buildSectionTitle('Amount'),
                    const SizedBox(height: 12),
                    _buildAmountFilter(),
                    const SizedBox(height: AppDesignTokens.space20),
                  ],

                  // Custom filter widgets
                  if (widget.customFilterWidgets != null)
                    ...widget.customFilterWidgets!,

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildQuickDateChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // All Time chip
        FilterChip(
          label: const Text('All Time'),
          selected: _filter.datePreset == null && _filter.startDate == null,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _filter = _filter.copyWith(clearDates: true);
              });
            }
          },
        ),
        // Preset chips
        ...QuickFilterOption.datePresets.map((preset) {
          final isSelected = _filter.datePreset == preset.id;
          return FilterChip(
            avatar: preset.icon != null
                ? Icon(
                    preset.icon,
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : null,
                  )
                : null,
            label: Text(preset.label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected && preset.getStartDate != null) {
                final start = preset.getStartDate!();
                final end = preset.getEndDate?.call() ?? DateTime.now();
                setState(() {
                  _filter = _filter.copyWith(
                    startDate: DateTime(start.year, start.month, start.day),
                    endDate: DateTime(end.year, end.month, end.day, 23, 59, 59),
                    datePreset: preset.id,
                  );
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildCustomDateRange() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final hasCustomRange = _filter.datePreset == 'custom' ||
        (_filter.startDate != null && _filter.datePreset == null);

    return InkWell(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: _filter.startDate != null && _filter.endDate != null
              ? DateTimeRange(
                  start: _filter.startDate!,
                  end: _filter.endDate!,
                )
              : null,
        );
        if (range != null) {
          setState(() {
            _filter = _filter.copyWith(
              startDate: range.start,
              endDate: DateTime(
                range.end.year,
                range.end.month,
                range.end.day,
                23,
                59,
                59,
              ),
              datePreset: 'custom',
            );
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasCustomRange
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: hasCustomRange ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasCustomRange
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: hasCustomRange
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasCustomRange && _filter.startDate != null
                    ? '${dateFormat.format(_filter.startDate!)} - ${dateFormat.format(_filter.endDate!)}'
                    : 'Select custom range...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: hasCustomRange
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All Categories'),
          selected: _filter.categoryId == null,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _filter = _filter.copyWith(clearCategory: true);
              });
            }
          },
        ),
        ...widget.categories!.map((category) {
          final isSelected = _filter.categoryId == category.id;
          return FilterChip(
            avatar: category.icon != null
                ? Icon(
                    category.icon,
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : category.color,
                  )
                : null,
            label: Text(category.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _filter = _filter.copyWith(categoryId: category.id);
                } else {
                  _filter = _filter.copyWith(clearCategory: true);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildAccountChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All Accounts'),
          selected: _filter.accountId == null,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _filter = _filter.copyWith(clearAccount: true);
              });
            }
          },
        ),
        ...widget.accounts!.map((account) {
          final isSelected = _filter.accountId == account.id;
          return FilterChip(
            label: Text(account.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _filter = _filter.copyWith(accountId: account.id);
                } else {
                  _filter = _filter.copyWith(clearAccount: true);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildAmountFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Min',
              prefixText: 'E£ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              setState(() {
                _filter = _filter.copyWith(minAmount: amount);
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('-'),
        ),
        Expanded(
          child: TextField(
            controller: _maxAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Max',
              prefixText: 'E£ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              setState(() {
                _filter = _filter.copyWith(maxAmount: amount);
              });
            },
          ),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filter = FilterResult.empty();
      _minAmountController.clear();
      _maxAmountController.clear();
      _searchController.clear();
    });
  }
}

/// Quick filter bar widget for showing active filters and quick presets
class QuickFilterBar extends StatelessWidget {
  final FilterResult currentFilter;
  final List<CategoryFilterOption>? categories;
  final List<AccountFilterOption>? accounts;
  final VoidCallback onFilterTap;
  final ValueChanged<FilterResult> onQuickFilterChanged;

  const QuickFilterBar({
    super.key,
    required this.currentFilter,
    this.categories,
    this.accounts,
    required this.onFilterTap,
    required this.onQuickFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter button
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: currentFilter.hasActiveFilters
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: currentFilter.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentFilter.hasActiveFilters
                        ? 'Filters (${currentFilter.activeFilterCount})'
                        : 'Filters',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: currentFilter.hasActiveFilters
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Quick filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: QuickFilterOption.datePresets.map((preset) {
                  final isSelected = currentFilter.datePreset == preset.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(preset.label),
                      selected: isSelected,
                      visualDensity: VisualDensity.compact,
                      onSelected: (selected) {
                        if (selected && preset.getStartDate != null) {
                          final start = preset.getStartDate!();
                          final end =
                              preset.getEndDate?.call() ?? DateTime.now();
                          onQuickFilterChanged(
                            currentFilter.copyWith(
                              startDate:
                                  DateTime(start.year, start.month, start.day),
                              endDate: DateTime(
                                end.year,
                                end.month,
                                end.day,
                                23,
                                59,
                                59,
                              ),
                              datePreset: preset.id,
                            ),
                          );
                        } else {
                          onQuickFilterChanged(
                            currentFilter.copyWith(clearDates: true),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
