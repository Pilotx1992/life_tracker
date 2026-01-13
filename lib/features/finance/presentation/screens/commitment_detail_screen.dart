import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';
import 'package:life_tracker/features/finance/presentation/providers/commitment_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_commitment_dialog.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_contribution_dialog.dart';

class CommitmentDetailScreen extends ConsumerWidget {
  final FinancialCommitment commitment;

  const CommitmentDetailScreen({
    super.key,
    required this.commitment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    final remainingAmount = commitment.targetAmount - commitment.currentAmount;
    final progressPercentage =
        (commitment.currentAmount / commitment.targetAmount * 100)
            .clamp(0, 100);
    final isCompleted = commitment.isCompleted;

    // Calculate days remaining
    final now = DateTime.now();
    final daysRemaining = commitment.deadline.difference(now).inDays;
    final isOverdue = daysRemaining < 0 && !isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(commitment.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Commitment',
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) =>
                    AddCommitmentDialog(commitment: commitment),
              );
              if (result == true && context.mounted) {
                // Pop back to the list and let it refresh
                context.pop();
                FeedbackService.showSuccess(context, 'Commitment updated');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Commitment',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppDesignTokens.space16,
          right: AppDesignTokens.space16,
          top: AppDesignTokens.space16,
          bottom: 88, // Space for FAB
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: isCompleted ? Colors.green.shade50 : null,
              child: Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Financial Goal',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.financePrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else if (isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.space16),
                    // Amount Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Amount',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              currencyFormat.format(commitment.targetAmount),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Current Amount',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              currencyFormat.format(commitment.currentAmount),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? Colors.green
                                        : AppColors.financePrimary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          currencyFormat.format(remainingAmount),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    isCompleted ? Colors.green : Colors.orange,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.space16),
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${progressPercentage.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressPercentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? Colors.green
                                : AppColors.financePrimary,
                          ),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),

            // Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDesignTokens.space16),
                    _buildDetailRow(
                      context,
                      'Target Date',
                      dateFormat.format(commitment.deadline),
                      Icons.calendar_today,
                      isWarning: isOverdue,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Days Remaining',
                      isCompleted
                          ? 'Completed'
                          : daysRemaining > 0
                              ? '$daysRemaining days'
                              : '${daysRemaining.abs()} days overdue',
                      Icons.access_time,
                      isWarning: isOverdue,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Created',
                      dateFormat.format(commitment.createdAt),
                      Icons.add_circle_outline,
                    ),
                    if (commitment.description.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        commitment.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),

            // Contribution History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Contribution History',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          currencyFormat.format(commitment.currentAmount),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDesignTokens.space16),
                    FutureBuilder<List<CommitmentContribution>>(
                      future: ref
                          .read(commitmentNotifierProvider.notifier)
                          .getContributionsByCommitment(commitment.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final contributions = snapshot.data ?? [];

                        if (contributions.isEmpty) {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppDesignTokens.space24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.savings,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No contributions yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: contributions.length,
                          itemBuilder: (context, index) {
                            final contribution = contributions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                                ),
                                title: Text(
                                  currencyFormat.format(contribution.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  dateFormat.format(contribution.date),
                                ),
                                trailing: contribution.note != null &&
                                        contribution.note!.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Contribution Note',
                                              ),
                                              content: Text(contribution.note!),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
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
            ),
          ],
        ),
      ),
      floatingActionButton: isCompleted
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddContributionDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Contribution'),
            ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning ? Colors.orange : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isWarning ? Colors.orange : null,
                        fontWeight: isWarning ? FontWeight.bold : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContributionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddContributionDialog(commitment: commitment),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Commitment?'),
        content: Text('Are you sure you want to delete "${commitment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(commitmentNotifierProvider.notifier)
          .deleteCommitmentEntry(commitment.id!);
      if (context.mounted) {
        Navigator.of(context).pop();
        FeedbackService.showSuccess(context, 'Commitment deleted');
      }
    }
  }
}
