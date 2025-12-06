import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
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
    _tabController = TabController(length: 3, vsync: this);
    // Delay refresh until after widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshReminders() async {
    await ref.read(reminderNotifierProvider.notifier).loadReminders();
  }

  void _showAddReminderDialog({Reminder? reminder}) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    );
  }

  void _deleteReminder(Id id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(reminderNotifierProvider.notifier).deleteReminderEntry(id);
    }
  }

  List<Reminder> _groupReminders(List<Reminder> reminders) {
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
    final allRemindersAsync = ref.watch(reminderNotifierProvider);
    final upcomingRemindersAsync = ref.watch(upcomingRemindersProvider);
    final completedRemindersAsync = ref.watch(completedRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReminderList(
            upcomingRemindersAsync,
            'No upcoming reminders. Tap + to add one!',
            'Upcoming',
          ),
          _buildReminderList(
            completedRemindersAsync,
            'No completed reminders yet.',
            'Completed',
          ),
          _buildReminderList(
            allRemindersAsync,
            'No reminders added yet. Tap + to add your first reminder!',
            'All',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderList(
    AsyncValue<List<Reminder>> remindersAsync,
    String emptyMessage,
    String sectionTitle,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshReminders,
      child: remindersAsync.when(
        loading: () => SkeletonList.cards(itemCount: 6),
        error: (error, stack) => ErrorStateWidget(message: error.toString()),
        data: (reminders) {
          if (reminders.isEmpty) {
            return EmptyStateWidget(
              title: emptyMessage,
              icon: Icons.notifications_none,
            );
          }

          // Group reminders for "Upcoming" and "All" tabs
          final groupedReminders = sectionTitle == 'Completed'
              ? reminders
              : _groupReminders(reminders);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            cacheExtent: 500,
            itemCount: groupedReminders.length,
            itemBuilder: (context, index) {
              final reminder = groupedReminders[index];
              return Dismissible(
                key: Key('reminder_${reminder.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsetsDirectional.only(end: 20),
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
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (direction) {
                  _deleteReminder(reminder.id!);
                },
                child: ReminderCard(
                  reminder: reminder,
                  onTap: () => _showAddReminderDialog(reminder: reminder),
                  onMarkDone: reminder.isCompleted
                      ? null
                      : () => ref
                          .read(reminderNotifierProvider.notifier)
                          .markReminderAsCompleted(reminder.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
