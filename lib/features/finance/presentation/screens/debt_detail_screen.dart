import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';
import 'package:life_tracker/features/finance/presentation/providers/debt_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_debt_payment_dialog.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final Debt debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final debt = widget.debt;
    final progress = debt.amount > 0 ? (debt.paidAmount / debt.amount) : 0.0;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(debt.person),
        actions: [
          if (!debt.isPaid)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () => _markAsPaid(context, debt),
              tooltip: 'Mark as Paid',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(debt.amount),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: debt.type == 'i_owe'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paid Amount',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(debt.paidAmount),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(debt.remainingAmount),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: debt.remainingAmount > 0
                                        ? (debt.type == 'i_owe'
                                            ? Colors.red
                                            : Colors.green)
                                        : Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!debt.isPaid && debt.amount > 0) ...[
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          debt.type == 'i_owe' ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% paid',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else if (debt.isPaid) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Fully Paid',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Type',
                      debt.type == 'i_owe' ? 'I Owe' : 'Owed to Me',
                    ),
                    _buildDetailRow(
                      context,
                      'Due Date',
                      dateFormat.format(debt.dueDate),
                      isOverdue: debt.isOverdue,
                    ),
                    if (debt.createdAt != null)
                      _buildDetailRow(
                        context,
                        'Created',
                        dateFormat.format(debt.createdAt!),
                      ),
                    if (debt.note != null && debt.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Note',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(debt.note!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Payment History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!debt.isPaid)
                  ElevatedButton.icon(
                    onPressed: () => _showAddPaymentDialog(context, debt),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<DebtPayment>>(
              future:
                  ref.read(debtNotifierProvider.notifier).getPayments(debt.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final payments = snapshot.data ?? [];

                if (payments.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No payments recorded yet',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.payment, color: Colors.green),
                        title: Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(payment.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          dateFormat.format(payment.paymentDate),
                        ),
                        trailing: payment.note != null
                            ? IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Payment Note'),
                                      content: Text(payment.note!),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isOverdue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? Colors.red : null,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentDialog(BuildContext context, Debt debt) async {
    await showDialog(
      context: context,
      builder: (context) => AddDebtPaymentDialog(debt: debt),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _markAsPaid(BuildContext context, Debt debt) {
    if (debt.id == null) return;

    // Capture parent context for feedback
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: const Text('Mark this debt as fully paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedDebt = debt.copyWith(
                isPaid: true,
                paidAmount: debt.amount,
              );
              ref
                  .read(debtNotifierProvider.notifier)
                  .updateDebtEntry(updatedDebt);
              Navigator.of(dialogContext).pop();
              FeedbackService.showSuccess(parentContext, 'Debt marked as paid');
            },
            child: const Text('Mark Paid'),
          ),
        ],
      ),
    );
  }
}
