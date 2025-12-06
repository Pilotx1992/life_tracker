import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';

class IncomeListItem extends StatelessWidget {
  final Income income;
  final Account? account;
  final VoidCallback onTap;

  const IncomeListItem({
    super.key,
    required this.income,
    this.account,
    required this.onTap,
  });

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.computer;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'other':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getSourceColor(String source, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (source.toLowerCase()) {
      case 'salary':
        return Colors.blue;
      case 'freelance':
        return Colors.purple;
      case 'investment':
        return Colors.green;
      case 'gift':
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EGP':
        return 'E£';
      default:
        return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: _getCurrencySymbol(income.currency));
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Source Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getSourceColor(income.source, context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSourceIcon(income.source),
                  color: _getSourceColor(income.source, context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Income Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          income.source,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (income.isRecurring) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.repeat,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(income.date)} ${timeFormat.format(income.date)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ],
                    ),
                    if (income.note != null && income.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        income.note!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Account info with navigation
                    if (account != null) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => context.push(
                          AppRoutes.accountDetail,
                          extra: account,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              account!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(income.amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  if (income.recurringFrequency != null)
                    Text(
                      income.recurringFrequency!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
