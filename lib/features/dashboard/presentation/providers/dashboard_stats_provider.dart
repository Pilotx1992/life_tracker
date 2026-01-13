import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/presentation/providers/activity_provider.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';

/// Dashboard statistics model
class DashboardStats {
  final int activityPercentage;
  final int pendingTasks;
  final String healthStatus;
  final double totalBalance;
  final String currency;

  const DashboardStats({
    required this.activityPercentage,
    required this.pendingTasks,
    required this.healthStatus,
    required this.totalBalance,
    required this.currency,
  });
}

/// Provider for dashboard statistics
final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  // Watch all required providers
  final activityAsync = ref.watch(activitySummaryStreamProvider);
  final remindersAsync = ref.watch(reminderListProvider);
  final accountsAsync = ref.watch(accountListProvider);
  // Use the same totalBalance calculation as accounts screen
  final totalBalance = ref.watch(totalBalanceProvider);

  // Combine all async values
  return activityAsync.when(
    data: (activity) {
      // Calculate activity percentage (steps / 10000 goal)
      final activityPercent =
          ((activity.steps / 10000) * 100).clamp(0, 100).toInt();

      // Get health status based on activity
      String healthStatus;
      if (activityPercent >= 80) {
        healthStatus = 'Excellent';
      } else if (activityPercent >= 60) {
        healthStatus = 'Good';
      } else if (activityPercent >= 40) {
        healthStatus = 'Fair';
      } else {
        healthStatus = 'Low';
      }

      // Get pending tasks count (only standalone reminders, not linked ones)
      final int pendingTasks = remindersAsync.maybeWhen(
        data: (reminders) => reminders
            .where((r) => !r.isCompleted && r.linkedType == null)
            .length,
        orElse: () => 0,
      );

      // Get total balance and currency
      final double balance = totalBalance ?? 0.0;
      final String currency = accountsAsync.maybeWhen(
        data: (accounts) => accounts.isNotEmpty ? accounts.first.currency : 'EGP',
        orElse: () => 'EGP',
      );

      return AsyncValue.data(
        DashboardStats(
          activityPercentage: activityPercent,
          pendingTasks: pendingTasks,
          healthStatus: healthStatus,
          totalBalance: balance,
          currency: currency,
        ),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
