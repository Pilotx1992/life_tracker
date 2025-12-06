import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';

class DebtListItem extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;

  const DebtListItem({
    super.key,
    required this.debt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIOwe = debt.type == 'i_owe';
    final isOverdue = debt.isOverdue;
    final isPaid = debt.isPaid;

    // Determine colors
    final mainColor = isIOwe ? AppColors.error : AppColors.success;
    final backgroundColor = theme.cardColor;

    // Date formatting
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Progress for partial payment
    final progress = debt.amount > 0
        ? (debt.remainingAmount / debt.amount).clamp(0.0, 1.0)
        : 0.0;

    // Paid percentage for visual loop (inverse of remaining)
    final paidPercentage = 1.0 - progress;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.space12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        border: Border.all(
          color: isOverdue
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.space16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar / Icon
                    _buildAvatar(context, isIOwe, mainColor),

                    const SizedBox(width: AppDesignTokens.space16),

                    // Center Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.person,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPaid
                                    ? 'Paid on ${dateFormat.format(DateTime.now())}' // Ideal: debt.paidDate
                                    : 'Due ${dateFormat.format(debt.dueDate)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isOverdue && !isPaid
                                      ? colorScheme.error
                                      : colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                  fontWeight: isOverdue && !isPaid
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right Side: Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$')
                              .format(debt.remainingAmount),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isPaid
                                ? colorScheme.onSurface.withValues(alpha: 0.4)
                                : mainColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (debt.amount != debt.remainingAmount && !isPaid)
                          Text(
                            'of ${NumberFormat.currency(symbol: '\$').format(debt.amount)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        if (isPaid)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'COMPLETED',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Progress Bar (Only if not paid and active)
                if (!isPaid && debt.amount > 0) ...[
                  const SizedBox(height: AppDesignTokens.space16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:
                          paidPercentage, // Show how much is PAID? Or remaining? Usually show PAID progress.
                      // Wait, old code was `debt.remainingAmount / debt.amount`. That is "Remaining %".
                      // If I owe $1000 and paid $200, remaining is $800 (0.8).
                      // A progress bar usually shows "Completion".
                      // So `1.0 - (remaining/total)`.
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(paidPercentage * 100).toInt()}% Paid',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isOverdue)
                        Text(
                          'OVERDUE',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isIOwe, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isIOwe ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}
