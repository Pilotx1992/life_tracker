import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'e-wallet':
        return Icons.account_balance_wallet;
      case 'credit card':
        return Icons.credit_card;
      default:
        return Icons.account_balance;
    }
  }

  Color _getAccountColor(String type, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type.toLowerCase()) {
      case 'bank':
        return colorScheme.primary;
      case 'cash':
        return Colors.green;
      case 'card':
        return colorScheme.secondary;
      case 'e-wallet':
        return Colors.orange;
      case 'credit card':
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '');

    final accountColor = _getAccountColor(account.type, context);
    final isCreditCard = account.type.toLowerCase() == 'credit card';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isCreditCard
                ? Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Account Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accountColor,
                      accountColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accountColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Account Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accountColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            account.type,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: accountColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                          ),
                        ),
                        if (account.bankName != null ||
                            account.cardLastDigits != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            account.bankName ?? '****${account.cardLastDigits}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${account.balance >= 0 ? '+' : ''}${currencyFormat.format(account.balance)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCreditCard
                              ? Colors.orange
                              : account.balance >= 0
                                  ? Colors.green
                                  : Colors.red,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      account.currency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
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
