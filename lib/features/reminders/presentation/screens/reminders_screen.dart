import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:life_tracker/features/reminders/presentation/widgets/add_reminder_dialog.dart';
import 'package:life_tracker/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshReminders() async {
    await ref.read(reminderListProvider.notifier).refresh();
  }

  void _showAddReminderDialog({Reminder? reminder}) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    );
  }

  /// Group reminders by time period for better UX
  List<Reminder> _sortRemindersByPeriod(List<Reminder> reminders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekFromNow = today.add(const Duration(days: 7));

    final todayReminders = <Reminder>[];
    final tomorrowReminders = <Reminder>[];
    final thisWeekReminders = <Reminder>[];
    final laterReminders = <Reminder>[];

    for (final reminder in reminders) {
      final reminderDate = DateTime(
        reminder.dateTime.year,
        reminder.dateTime.month,
        reminder.dateTime.day,
      );

      if (reminderDate == today) {
        todayReminders.add(reminder);
      } else if (reminderDate == tomorrow) {
        tomorrowReminders.add(reminder);
      } else if (reminderDate.isBefore(weekFromNow)) {
        thisWeekReminders.add(reminder);
      } else {
        laterReminders.add(reminder);
      }
    }

    return [
      ...todayReminders,
      ...tomorrowReminders,
      ...thisWeekReminders,
      ...laterReminders,
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main provider for loading/error states
    final remindersAsync = ref.watch(reminderListProvider);

    // Watch derived providers for filtered lists
    final upcomingReminders = ref.watch(upcomingRemindersProvider);
    final completedReminders = ref.watch(completedRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: remindersAsync.when(
        loading: () => SkeletonList.cards(itemCount: 6),
        error: (error, stack) => ErrorStateWidget(
          message: error.toString(),
          onRetry: _refreshReminders,
        ),
        data: (_) => TabBarView(
          controller: _tabController,
          children: [
            _buildReminderList(
              _sortRemindersByPeriod(upcomingReminders),
              'No upcoming reminders. Tap + to add one!',
              isCompleted: false,
            ),
            _buildReminderList(
              completedReminders,
              'No completed reminders yet.',
              isCompleted: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderList(
    List<Reminder> reminders,
    String emptyMessage, {
    required bool isCompleted,
  }) {
    if (reminders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshReminders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: EmptyStateWidget(
                title: emptyMessage,
                icon: Icons.notifications_none,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReminders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 500,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderItem(reminder, isCompleted);
        },
      ),
    );
  }

  Widget _buildReminderItem(Reminder reminder, bool isCompleted) {
    return Dismissible(
      key: ValueKey('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Reminder'),
                content: Text(
                  'Are you sure you want to delete "${reminder.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        final reminderId = reminder.id;
        if (reminderId != null) {
          final success = await ref
              .read(reminderListProvider.notifier)
              .deleteReminder(reminderId);

          if (!success && mounted) {
            FeedbackService.showError(context, 'Failed to delete reminder');
          }
        }
      },
      child: ReminderCard(
        reminder: reminder,
        onTap: () => _showAddReminderDialog(reminder: reminder),
        onMarkDone: isCompleted
            ? null
            : () async {
                final success = await ref
                    .read(reminderListProvider.notifier)
                    .markAsCompleted(reminder.id!);

                if (success && mounted) {
                  FeedbackService.showSuccess(context, 'Reminder completed!');
                } else if (mounted) {
                  FeedbackService.showError(
                      context, 'Failed to complete reminder');
                }
              },
      ),
    );
  }
}
