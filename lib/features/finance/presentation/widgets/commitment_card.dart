import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';

class CommitmentCard extends StatelessWidget {
  final FinancialCommitment commitment;
  final VoidCallback? onTap;
  final VoidCallback? onAddContribution;
  final VoidCallback? onEdit;

  const CommitmentCard({
    super.key,
    required this.commitment,
    this.onTap,
    this.onAddContribution,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = commitment.progress;
    final percentage = (progress * 100).toStringAsFixed(1);
    final daysRemaining = commitment.daysRemaining;
    final suggestedMonthly = commitment.suggestedMonthlySavings;
    final isOverdue = commitment.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: isOverdue
                ? Border.all(color: Colors.red, width: 2)
                : commitment.isCompleted
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: commitment.isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : isOverdue
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      commitment.isCompleted
                          ? Icons.check_circle
                          : Icons.savings,
                      color: commitment.isCompleted
                          ? Colors.green
                          : isOverdue
                              ? Colors.red
                              : Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commitment.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (commitment.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            commitment.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Actions Menu
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      if (!commitment.isCompleted)
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle, size: 20),
                              SizedBox(width: 8),
                              Text('Add Contribution'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () => onAddContribution?.call(),
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
                            () => onEdit?.call(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        '$percentage%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: commitment.isCompleted
                                  ? Colors.green
                                  : isOverdue
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      commitment.isCompleted
                          ? Colors.green
                          : isOverdue
                              ? Colors.red
                              : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Amount Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$')
                            .format(commitment.currentAmount),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$')
                            .format(commitment.targetAmount),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.calendar_today,
                      'Days Left',
                      daysRemaining > 0 ? daysRemaining.toString() : 'Overdue',
                      daysRemaining > 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      Icons.trending_up,
                      'Monthly',
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                          .format(suggestedMonthly),
                      Colors.green,
                    ),
                  ),
                ],
              ),
              // Status Badge
              if (commitment.isCompleted) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ] else if (isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Overdue',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
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
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
