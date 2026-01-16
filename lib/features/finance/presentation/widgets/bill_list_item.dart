import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_bill_dialog.dart';
import 'package:life_tracker/features/finance/presentation/widgets/make_payment_dialog.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

class BillListItem extends ConsumerWidget {
  final RecurringBill bill;

  const BillListItem({super.key, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      bill.nextDueDate.year,
      bill.nextDueDate.month,
      bill.nextDueDate.day,
    );

    // Check if bill is overdue (only if active and not fully paid)
    final isOverdue = bill.isActive &&
                      !bill.isFullyPaid &&
                      dueDate.isBefore(today);
    final isDueToday = bill.isActive &&
                       !bill.isFullyPaid &&
                       dueDate.isAtSameMomentAs(today);

    String frequencyLabel = bill.frequency;
    if (bill.frequency.toLowerCase() == 'monthly') {
      frequencyLabel = 'Monthly (${_getDayLabel(bill.dayOfSchedule)})';
    } else if (bill.frequency.toLowerCase() == 'weekly') {
      frequencyLabel = 'Weekly (${_getWeekdayLabel(bill.dayOfSchedule)})';
    } else if (bill.frequency.toLowerCase() == 'yearly') {
      frequencyLabel = 'Yearly (${_getDayLabel(bill.dayOfSchedule)})';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: isOverdue
              ? Border.all(color: Colors.red, width: 2)
              : isDueToday
                  ? Border.all(color: Colors.orange, width: 2)
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Bill Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bill.isActive
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: bill.isActive ? Colors.blue : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Bill Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bill.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (!bill.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            DateFormat('d MMM').format(bill.nextDueDate),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isOverdue
                                          ? Colors.red
                                          : isDueToday
                                              ? Colors.orange
                                              : null,
                                      fontWeight: isOverdue || isDueToday
                                          ? FontWeight.bold
                                          : null,
                                    ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        frequencyLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(symbol: '\$').format(bill.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: bill.isActive ? Colors.blue : Colors.grey,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Actions
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (bill.isActive)
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.payment, size: 20),
                            SizedBox(width: 8),
                            Text('Pay'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () {
                              if (context.mounted) {
                                // Use unified payment dialog for both bills and installments
                                showMakePaymentDialog(context, bill);
                              }
                            },
                          );
                        },
                      ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AddBillDialog(bill: bill),
                              );
                            }
                          },
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () {
                            if (bill.id != null && context.mounted) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Bill'),
                                  content: Text(
                                    'Are you sure you want to delete "${bill.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        ref
                                            .read(billNotifierProvider.notifier)
                                            .deleteBillEntry(bill.id!);
                                        Navigator.pop(ctx);
                                        FeedbackService.showSuccess(
                                          context,
                                          '${bill.name} deleted',
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(int day) {
    return '$day${_getDaySuffix(day)}';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getWeekdayLabel(int dayOfWeek) {
    // dayOfWeek: 1=Monday, 7=Sunday
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return weekdays[dayOfWeek - 1];
    }
    return 'Day $dayOfWeek';
  }
}
