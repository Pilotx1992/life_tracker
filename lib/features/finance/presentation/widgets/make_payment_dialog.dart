import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

/// Dialog for making a payment on a bill or installment
class MakePaymentDialog extends ConsumerStatefulWidget {
  final RecurringBill bill;

  const MakePaymentDialog({
    super.key,
    required this.bill,
  });

  @override
  ConsumerState<MakePaymentDialog> createState() => _MakePaymentDialogState();
}

class _MakePaymentDialogState extends ConsumerState<MakePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isFullPayment = true;
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    // Default to the regular bill/installment amount
    double initialAmount = widget.bill.amount;
    // For installments, cap at remaining amount
    if (widget.bill.isInstallment &&
        initialAmount > widget.bill.remainingAmount) {
      initialAmount = widget.bill.remainingAmount;
    }
    _amountController.text = initialAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = widget.bill;
    final formatter =
        NumberFormat.currency(symbol: '${bill.currency} ', decimalDigits: 2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Make Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bill.name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress card (Only for installments)
                      if (bill.isInstallment)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: bill.progressPercentage / 100,
                                  minHeight: 10,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHigh,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    bill.progressPercentage >= 100
                                        ? Colors.green
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Stats row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatItem(
                                      theme,
                                      'Paid',
                                      formatter.format(bill.paidAmount),
                                      Colors.green,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      theme,
                                      'Remaining',
                                      formatter.format(bill.remainingAmount),
                                      theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        // Simple Amount Display for Regular Bills
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Total Amount',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatter.format(bill.amount),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Payment type - Material 3 SegmentedButton
                      Text(
                        'Payment Type',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Full Payment'),
                            icon: Icon(Icons.payments_rounded, size: 18),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Custom Amount'),
                            icon: Icon(Icons.edit_rounded, size: 18),
                          ),
                        ],
                        selected: {_isFullPayment},
                        onSelectionChanged: (Set<bool> selection) {
                          setState(() {
                            _isFullPayment = selection.first;
                            if (_isFullPayment) {
                              double amount = bill.amount;
                              // For installments, cap at remaining amount
                              if (bill.isInstallment &&
                                  amount > bill.remainingAmount) {
                                amount = bill.remainingAmount;
                              }
                              _amountController.text =
                                  amount.toStringAsFixed(2);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        enabled: !_isFullPayment,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: bill.currency,
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          // Only check remaining balance for installments
                          if (bill.isInstallment &&
                              amount > bill.remainingAmount) {
                            return 'Amount exceeds remaining balance';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Account dropdown (for all bills and installments)
                      Consumer(
                        builder: (context, ref, _) {
                          final accountsAsync = ref.watch(accountListProvider);

                          return accountsAsync.when(
                            data: (accounts) {
                              if (accounts.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_rounded,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'No accounts available. Please add an account first.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              _selectedAccount ??= accounts.first;

                              return DropdownButtonFormField<Account>(
                                initialValue: _selectedAccount,
                                decoration: InputDecoration(
                                  labelText: 'Pay from Account',
                                  prefixIcon:
                                      const Icon(Icons.account_balance_wallet),
                                  filled: true,
                                  fillColor: theme
                                      .colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                isExpanded: true,
                                items: accounts.map((account) {
                                  final balanceText = NumberFormat.currency(
                                    symbol: account.currency,
                                    decimalDigits: 0,
                                  ).format(account.balance);

                                  return DropdownMenuItem(
                                    value: account,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            account.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          balanceText,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAccount = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an account';
                                  }
                                  return null;
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Error loading accounts',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Note field
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Note (optional)',
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      FilledButton.icon(
                        icon: const Icon(Icons.payment_rounded),
                        label: const Text('Confirm Payment'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Validate account selection
    if (_selectedAccount == null) {
      if (!mounted) return;
      FeedbackService.showError(context, 'Please select an account');
      return;
    }

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    // Add account to bill before payment
    final billWithAccount = widget.bill.copyWith(
      accountId: _selectedAccount!.id,
    );

    // Check if this is an installment or regular bill
    if (widget.bill.isInstallment) {
      // For installments, use makeInstallmentPayment
      ref.read(billNotifierProvider.notifier).makeInstallmentPayment(
            billWithAccount,
            amount: amount,
            note: note,
          );
    } else {
      // For regular bills, use markBillAsPaid
      ref.read(billNotifierProvider.notifier).markBillAsPaid(billWithAccount);
    }

    if (!mounted) return;

    Navigator.pop(context);

    if (!mounted) return;

    FeedbackService.showSuccess(
      context,
      'Payment of ${widget.bill.currency} ${amount.toStringAsFixed(2)} recorded',
    );
  }
}

/// Shows the make payment dialog for bills and installments
Future<void> showMakePaymentDialog(
  BuildContext context,
  RecurringBill bill,
) async {
  await showDialog(
    context: context,
    builder: (context) => MakePaymentDialog(bill: bill),
  );
}
