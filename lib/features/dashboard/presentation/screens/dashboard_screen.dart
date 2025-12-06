import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';

/// Dashboard screen - main entry point showing all modules
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // Listen for user profile availability and redirect to profile setup when missing.
    ref.listen<AsyncValue<dynamic>>(userProfileProvider, (previous, next) {
      if (next is AsyncData) {
        final profile = next.value as Object?;
        if (profile == null) {
          // Use a post frame callback to avoid navigation during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.push(AppRoutes.profileSetup);
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppDesignTokens.space8),
              Text(
                'Track your health, finances, notes, and reminders all in one place.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppDesignTokens.space24),

              // Module Cards Grid
              Text(
                'Modules',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppDesignTokens.space16),

              // Health Module
              _ModuleCard(
                icon: Icons.favorite,
                title: 'Health',
                subtitle: 'Track weight, medications, and health metrics',
                color: AppColors.healthPrimary,
                onTap: () => context.push(AppRoutes.weight),
              ),
              const SizedBox(height: AppDesignTokens.space12),

              // Finance Module
              _ModuleCard(
                icon: Icons.account_balance_wallet,
                title: 'Finance',
                subtitle: 'Manage expenses, income, and budgets',
                color: AppColors.financePrimary,
                onTap: () => context.push(AppRoutes.finance),
              ),
              const SizedBox(height: AppDesignTokens.space12),

              // Notes Module
              _ModuleCard(
                icon: Icons.note,
                title: 'Notes',
                subtitle: 'Create notes with checklists and attachments',
                color: AppColors.notesPrimary,
                onTap: () => context.push(AppRoutes.notes),
              ),
              const SizedBox(height: AppDesignTokens.space12),

              // Reminders Module
              _ModuleCard(
                icon: Icons.notifications,
                title: 'Reminders',
                subtitle: 'Set reminders and never forget important tasks',
                color: AppColors.remindersPrimary,
                onTap: () => context.push(AppRoutes.reminders),
              ),
              const SizedBox(height: AppDesignTokens.space24),

              // Dev / Diagnostics - Notification test (handy during development)
              _ModuleCard(
                icon: Icons.play_circle_fill,
                title: 'Dev: Notifications',
                subtitle: 'Test notification permissions & scheduling',
                color: AppColors.remindersPrimary,
                onTap: () => context.push(AppRoutes.notificationTest),
              ),
              const SizedBox(height: AppDesignTokens.space24),

              // Quick Stats Section (placeholder for future)
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppDesignTokens.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDesignTokens.space24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.radiusMedium,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.analytics,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppDesignTokens.space8),
                    Text(
                      'Statistics Coming Soon',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Module card widget
class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
