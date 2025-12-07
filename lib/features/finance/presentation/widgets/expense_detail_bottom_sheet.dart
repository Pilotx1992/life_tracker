import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/domain/entities/category.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/presentation/providers/expense_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'dart:io';

class ExpenseDetailBottomSheet extends ConsumerWidget {
  final Expense expense;
  final Category category;
  final Account? account;

  const ExpenseDetailBottomSheet({
    super.key,
    required this.expense,
    required this.category,
    this.account,
  });

  static void show(
    BuildContext context, {
    required Expense expense,
    required Category category,
    Account? account,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseDetailBottomSheet(
        expense: expense,
        category: category,
        account: account,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'EGP ');
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final hasReceipt = expense.receiptPath != null;

    return DraggableScrollableSheet(
      initialChildSize: hasReceipt ? 0.85 : 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              currencyFormat.format(expense.amount),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expense',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Category
                            _buildDetailRow(
                              context,
                              icon: Icons.category,
                              label: 'Category',
                              value: category.name,
                              iconColor: _getCategoryColor(category.color),
                            ),
                            const Divider(height: 24),

                            // Account
                            if (account != null) ...[
                              _buildDetailRow(
                                context,
                                icon: Icons.account_balance_wallet,
                                label: 'Account',
                                value: account!.name,
                                iconColor: theme.colorScheme.primary,
                              ),
                              const Divider(height: 24),
                            ],

                            // Date
                            _buildDetailRow(
                              context,
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: dateFormat.format(expense.date),
                              iconColor: Colors.orange,
                            ),

                            // Note
                            if (expense.note != null &&
                                expense.note!.isNotEmpty) ...[
                              const Divider(height: 24),
                              _buildDetailRow(
                                context,
                                icon: Icons.notes,
                                label: 'Note',
                                value: expense.note!,
                                iconColor: Colors.blue,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Receipt Section
                      if (hasReceipt) ...[
                        Text(
                          'Receipt',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReceiptImage(context, expense.receiptPath!),
                        const SizedBox(height: 20),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          // Edit Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: theme.colorScheme.surface,
                                  builder: (context) => AddExpenseBottomSheet(
                                    expense: expense,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete Button
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _confirmDelete(context, ref, expense),
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptImage(BuildContext context, String receiptPath) {
    final file = File(receiptPath);
    final theme = Theme.of(context);

    if (!file.existsSync()) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Text(
              'Receipt image not found',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, file),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              file,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              // Optimize memory usage by caching at display size
              cacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).round(),
              cacheHeight: (200 * MediaQuery.of(context).devicePixelRatio).round(),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: theme.colorScheme.errorContainer,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              },
            ),
            // Overlay hint to view full screen
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Tap to view',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, File file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Receipt',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                file,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Revert account balance
        if (account != null) {
          final updatedAccount = account!.copyWith(
            balance: account!.balance + expense.amount,
          );
          await ref
              .read(accountNotifierProvider.notifier)
              .updateAccountEntry(updatedAccount);
        }

        // Delete expense
        await ref
            .read(expenseNotifierProvider.notifier)
            .deleteExpenseEntry(expense.id!);

        if (context.mounted) {
          Navigator.of(context).pop();
          FeedbackService.showSuccess(context, 'Expense deleted');
        }
      } catch (e) {
        if (context.mounted) {
          FeedbackService.showError(context, 'Failed to delete: $e');
        }
      }
    }
  }

  Color _getCategoryColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
