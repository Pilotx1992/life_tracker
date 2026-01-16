import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

/// Dialog for making a payment on an installment
class MakePaymentDialog extends ConsumerStatefulWidget {
  final RecurringBill installment;

  const MakePaymentDialog({
    super.key,
    required this.installment,
  });

  @override
  ConsumerState<MakePaymentDialog> createState() => _MakePaymentDialogState();
}

class _MakePaymentDialogState extends ConsumerState<MakePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isFullPayment = true;

  @override
  void initState() {
    super.initState();
    // Default to the regular installment amount
    _amountController.text = widget.installment.amount.toStringAsFixed(2);
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
    final bill = widget.installment;
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
                      // Progress card
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
                      ),
                      const SizedBox(height: 20),

                      // Payment type - using Column for compact display
                      Text(
                        'Payment Type',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPaymentTypeCard(
                              theme,
                              'Full',
                              Icons.check_circle_rounded,
                              _isFullPayment,
                              () {
                                setState(() {
                                  _isFullPayment = true;
                                  _amountController.text =
                                      bill.amount.toStringAsFixed(2);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentTypeCard(
                              theme,
                              'Custom',
                              Icons.edit_rounded,
                              !_isFullPayment,
                              () {
                                setState(() {
                                  _isFullPayment = false;
                                });
                              },
                            ),
                          ),
                        ],
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
                            decimal: true,),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          if (amount > bill.remainingAmount) {
                            return 'Amount exceeds remaining balance';
                          }
                          return null;
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
      ThemeData theme, String label, String value, Color color,) {
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

  Widget _buildPaymentTypeCard(
    ThemeData theme,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    ref.read(billNotifierProvider.notifier).makeInstallmentPayment(
          widget.installment,
          amount: amount,
          note: note,
        );

    if (!mounted) return;

    Navigator.pop(context);

    if (!mounted) return;

    FeedbackService.showSuccess(
      context,
      'Payment of ${widget.installment.currency} ${amount.toStringAsFixed(2)} recorded',
    );
  }
}

/// Shows the make payment dialog
Future<void> showMakePaymentDialog(
  BuildContext context,
  RecurringBill installment,
) async {
  await showDialog(
    context: context,
    builder: (context) => MakePaymentDialog(installment: installment),
  );
}
