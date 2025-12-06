import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';

class RemindersSummaryCard extends ConsumerWidget {
  const RemindersSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppRoutes.reminders),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            remindersAsync.when(
              data: (reminders) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final tomorrow = today.add(const Duration(days: 1));

                // Get today's reminders
                final todayReminders = reminders
                    .where(
                      (r) =>
                          !r.isCompleted &&
                          r.dateTime.isAfter(today) &&
                          r.dateTime.isBefore(tomorrow),
                    )
                    .toList();

                // Get next upcoming reminder
                final upcomingReminders = reminders
                    .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
                    .toList();
                upcomingReminders
                    .sort((a, b) => a.dateTime.compareTo(b.dateTime));

                if (todayReminders.isEmpty && upcomingReminders.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No reminders',
                    'Create reminders to stay organized',
                    () => context.push(AppRoutes.reminders),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's count
                    _buildTodayCount(context, todayReminders.length),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Next reminder
                    if (upcomingReminders.isNotEmpty)
                      _buildNextReminder(context, upcomingReminders.first),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
            const SizedBox(height: 16),
            // Quick Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.reminders),
                icon: const Icon(Icons.add),
                label: const Text('Add Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCount(BuildContext context, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.today, color: Colors.orange, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                '$count ${count == 1 ? 'reminder' : 'reminders'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextReminder(BuildContext context, Reminder reminder) {
    final isToday = reminder.dateTime.day == DateTime.now().day &&
        reminder.dateTime.month == DateTime.now().month &&
        reminder.dateTime.year == DateTime.now().year;

    return Row(
      children: [
        Icon(
          _getPriorityIcon(reminder.priority),
          size: 24,
          color: _getPriorityColor(reminder.priority),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                isToday
                    ? 'Today at ${DateFormat('hh:mm a').format(reminder.dateTime)}'
                    : DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(reminder.dateTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Error: $error',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
