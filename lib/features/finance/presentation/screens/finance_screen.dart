import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// Main Finance hub screen that provides navigation to all finance features
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFinanceCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Accounts',
                subtitle: 'Manage your bank accounts and balances',
                color: AppColors.financePrimary,
                onTap: () => context.push('/finance/accounts'),
              ),
              const SizedBox(height: AppDesignTokens.space4),
              _buildFinanceCard(
                context,
                icon: Icons.arrow_upward,
                title: 'Income',
                subtitle: 'Record your income and earnings',
                color: Colors.green,
                onTap: () => context.push('/finance/income'),
              ),
              const SizedBox(height: AppDesignTokens.space4),
              _buildFinanceCard(
                context,
                icon: Icons.arrow_downward,
                title: 'Expenses',
                subtitle: 'Track your spending and expenses',
                color: Colors.red,
                onTap: () => context.push('/finance/expenses'),
              ),
              const SizedBox(height: AppDesignTokens.space4),
              _buildFinanceCard(
                context,
                icon: Icons.receipt_long,
                title: 'Bills',
                subtitle: 'Manage recurring bills and payments',
                color: Colors.orange,
                onTap: () => context.push('/finance/bills'),
              ),
              const SizedBox(height: AppDesignTokens.space4),
              _buildFinanceCard(
                context,
                icon: Icons.credit_card,
                title: 'Debts',
                subtitle: 'Track debts and loan payments',
                color: Colors.deepPurple,
                onTap: () => context.push('/finance/debts'),
              ),
              const SizedBox(height: AppDesignTokens.space4),
              _buildFinanceCard(
                context,
                icon: Icons.savings,
                title: 'Commitments',
                subtitle: 'Track financial goals and savings',
                color: Colors.teal,
                onTap: () => context.push('/finance/commitments'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDesignTokens.space16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.radiusSmall,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDesignTokens.space16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDesignTokens.space4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
