import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/debt_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_debt_dialog.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  String _selectedView = 'i_owe'; // 'i_owe' or 'owed_to_me'

  // Helper widget to display currency with EGP normal and number bold
  Widget _buildCurrencyText(
    BuildContext context,
    double amount, {
    TextStyle? style,
  }) {
    final numberFormat = NumberFormat('#,##0.00');
    final formattedNumber = numberFormat.format(amount.abs());
    final sign = amount < 0 ? '-' : '';

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'EGP ',
            style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: '$sign$formattedNumber',
            style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use totalAssetsProvider which includes account balances + owed_to_me debts
    final iHaveTotal = ref.watch(totalAssetsProvider);
    final iOweTotal = ref.watch(totalIOweProvider);
    final accountsAsync = ref.watch(accountListProvider);

    // Calculate Net Worth: I have - I owe
    final iHave = iHaveTotal ?? 0.0;
    final iOwe = iOweTotal ?? 0.0;
    final netWorth = iHave - iOwe;

    // Calculate percentages for bars
    final total = iHave + iOwe;
    final iHavePercentage = total > 0 ? (iHave / total) : 0.0;
    final iOwePercentage = total > 0 ? (iOwe / total) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 88), // Space for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section - Overview with bars - 3D Style
            Padding(
              padding: const EdgeInsets.all(AppDesignTokens.space16),
              child: Container(
                padding: const EdgeInsets.all(AppDesignTokens.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    // Main shadow for depth
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                    // Secondary shadow for 3D effect
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Horizontal bars
                    Row(
                      children: [
                        Expanded(
                          flex: (iHavePercentage * 100).round().clamp(1, 100),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: (iOwePercentage * 100).round().clamp(1, 100),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // I have and I owe amounts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'I have',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildCurrencyText(
                                context,
                                iHave,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 228, 74, 63),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'I owe',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildCurrencyText(
                                context,
                                iOwe,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    const SizedBox(height: 20),
                    // Net Worth
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Net Worth',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildCurrencyText(
                            context,
                            netWorth,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: netWorth >= 0
                                      ? Colors.green
                                      : const Color.fromARGB(255, 241, 80, 68),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),
            // Toggle Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.space16,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        context,
                        'I have',
                        _selectedView == 'i_have',
                        () => setState(() => _selectedView = 'i_have'),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildToggleButton(
                        context,
                        'I owe',
                        _selectedView == 'i_owe',
                        () => setState(() => _selectedView = 'i_owe'),
                        const Color.fromARGB(255, 120, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),
            // Total amount card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.space16,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppDesignTokens.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total amount in ${DateFormat('d MMM yyyy').format(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildCurrencyText(
                      context,
                      _selectedView == 'i_have' ? iHave : iOwe,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),
            // Detail Cards
            if (_selectedView == 'i_have')
              _buildIHaveDetails(context, accountsAsync, iHave)
            else
              _buildIOweDetails(context, iOwe),
            const SizedBox(height: AppDesignTokens.space16),
            // Debts Lists
            if (_selectedView == 'i_owe')
              _buildDebtsList(context, ref, 'i_owe')
            else
              _buildDebtsList(context, ref, 'owed_to_me'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 34),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildIHaveDetails(
    BuildContext context,
    AsyncValue<List<Account>> accountsAsync,
    double total,
  ) {
    return accountsAsync.when(
      data: (accounts) {
        // Filter out Credit Card accounts
        final regularAccounts = accounts
            .where((a) => a.type.toLowerCase() != 'credit card')
            .toList();

        if (regularAccounts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.space16,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDesignTokens.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                context.push(AppRoutes.financeAccounts);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Accounts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildCurrencyText(
                          context,
                          total,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.outline,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildIOweDetails(
    BuildContext context,
    double total,
  ) {
    final creditCardDebtAsync = ref.watch(debtListProvider('i_owe'));
    final creditCardDebt = creditCardDebtAsync.when(
      data: (debts) {
        return debts.where((d) => d.note == 'Credit Card Debt').fold<double>(
              0.0,
              (sum, debt) => sum + (debt.amount - debt.paidAmount),
            );
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    final regularDebtTotal = total - creditCardDebt;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.space16,
      ),
      child: Column(
        children: [
          if (creditCardDebt > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(AppDesignTokens.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    // Navigate to accounts screen filtered to credit cards
                    context.push(AppRoutes.financeAccounts);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Credit cards',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            _buildCurrencyText(
                              context,
                              creditCardDebt,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.outline,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (regularDebtTotal > 0)
            Container(
              padding: const EdgeInsets.all(AppDesignTokens.space20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.red.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Other debts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildCurrencyText(
                          context,
                          regularDebtTotal,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(BuildContext context, WidgetRef ref, String debtType) {
    final debtsAsync = ref.watch(debtListProvider(debtType));
    final isIOwe = debtType == 'i_owe';
    final listTitle = isIOwe ? 'Other debts' : 'Owed to me';
    final iconColor = isIOwe ? Colors.red.shade700 : Colors.green.shade700;

    return debtsAsync.when(
      data: (debts) {
        // Filter out Credit Card debts - only show other debts
        final otherDebts =
            debts.where((d) => d.note != 'Credit Card Debt').toList();

        if (otherDebts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppDesignTokens.space8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otherDebts.length,
                itemBuilder: (context, index) {
                  final debt = otherDebts[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDesignTokens.radiusMedium),
                      side: BorderSide(
                          color: Theme.of(context).dividerColor, width: 1,),
                    ),
                    margin: const EdgeInsets.only(
                      bottom: AppDesignTokens.space8,
                    ),
                    child: InkWell(
                      onLongPress: () {
                        _showDebtOptionsMenu(context, ref, debt);
                      },
                      child: ListTile(
                        leading: Icon(
                          isIOwe
                              ? Icons.account_balance_wallet
                              : Icons.arrow_downward_rounded,
                          color: iconColor,
                        ),
                        title: Text(debt.person),
                        subtitle: Text(
                          'Due: ${DateFormat('MMM dd, yyyy').format(debt.dueDate)}',
                        ),
                        trailing: _buildCurrencyText(
                          context,
                          debt.amount - debt.paidAmount,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showDebtOptionsMenu(BuildContext context, WidgetRef ref, Debt debt) {
    // Store outer context reference before showing bottom sheet
    final outerContext = context;

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                // Use outer context for dialog since bottom sheet is now closed
                showDialog(
                  context: outerContext,
                  builder: (dialogContext) => AddDebtDialog(debt: debt),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                // Use outer context for confirmation dialog
                _confirmDeleteDebt(outerContext, ref, debt);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDebt(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Debt?'),
        content: const Text('Are you sure you want to delete this debt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(debtNotifierProvider.notifier)
          .deleteDebtEntry(debt.id!, debt.type);
      if (context.mounted) {
        FeedbackService.showSuccess(context, 'Debt deleted');
      }
    }
  }

  void _showAddDebtDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddDebtDialog(),
    );
  }
}
