import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double totalAmount;
  final String currency;
  final int expenseCount;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const ExpenseSummaryCard({
    super.key,
    required this.totalAmount,
    required this.currency,
    required this.expenseCount,
    this.periodStart,
    this.periodEnd,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
    );
    final dateFormat = DateFormat('MMM dd');

    String periodText = 'All Time';
    if (periodStart != null && periodEnd != null) {
      periodText =
          '${dateFormat.format(periodStart!)} - ${dateFormat.format(periodEnd!)}';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periodText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(totalAmount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.receipt,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '$expenseCount transactions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'EGP':
        return 'E£';
      default:
        return currency;
    }
  }
}
