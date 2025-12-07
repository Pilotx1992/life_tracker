import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/notes/presentation/providers/note_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';

class ReminderCard extends ConsumerWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback? onMarkDone;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    this.onMarkDone,
  });

  Color _getPriorityColor(BuildContext context, String priority) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (priority) {
      case 'High':
        return colorScheme.error;
      case 'Medium':
        return colorScheme.tertiary;
      case 'Low':
        return colorScheme.primary;
      default:
        return colorScheme.outline;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'High':
        return Icons.priority_high;
      case 'Medium':
        return Icons.remove;
      case 'Low':
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
  }

  String _getLinkedItemLabel(String? linkedType) {
    switch (linkedType) {
      case 'medication':
        return '💊 Medication';
      case 'bill':
        return '💰 Bill';
      case 'note':
        return '📝 Note';
      default:
        return '';
    }
  }

  void _navigateToLinkedItem(
    BuildContext context,
    WidgetRef ref,
    String linkedType,
    Id linkedId,
  ) {
    switch (linkedType) {
      case 'note':
        // Get the note and navigate to note detail
        final notes = ref.read(noteNotifierProvider).valueOrNull ?? [];
        final note = notes.where((n) => n.id == linkedId).firstOrNull;
        if (note != null) {
          context.push(AppRoutes.noteDetail, extra: note);
        } else {
          FeedbackService.showWarning(context, 'Note not found');
        }
        break;

      case 'medication':
        // Get the medication and navigate to medication detail
        final medications =
            ref.read(medicationNotifierProvider).valueOrNull ?? [];
        final medication =
            medications.where((m) => m.id == linkedId).firstOrNull;
        if (medication != null) {
          // Navigate to medications screen for now (medication detail would need to be added separately)
          context.push(AppRoutes.medications);
          FeedbackService.showInfo(
            context,
            'Viewing medication: ${medication.name}',
          );
        } else {
          FeedbackService.showWarning(context, 'Medication not found');
        }
        break;

      case 'bill':
        // Get the bill and navigate to bills screen
        final bills = ref.read(billNotifierProvider).valueOrNull ?? [];
        final bill = bills.where((b) => b.id == linkedId).firstOrNull;
        if (bill != null) {
          context.push(AppRoutes.financeBills);
          FeedbackService.showInfo(context, 'Viewing bill: ${bill.name}');
        } else {
          FeedbackService.showWarning(context, 'Bill not found');
        }
        break;

      default:
        FeedbackService.showError(context, 'Unknown linked type: $linkedType');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = _getPriorityColor(context, reminder.priority);
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: isOverdue
                ? Border.all(color: colorScheme.error, width: 2)
                : isDueToday
                    ? Border.all(color: colorScheme.tertiary, width: 2)
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Priority indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reminder.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: reminder.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Priority icon
                        Icon(
                          _getPriorityIcon(reminder.priority),
                          size: 16,
                          color: priorityColor,
                        ),
                        // Alarm icon
                        if (reminder.hasAlarm) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.alarm,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (reminder.description != null &&
                        reminder.description!.isNotEmpty)
                      Text(
                        reminder.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: reminder.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    // Linked item indicator
                    if (reminder.linkedType != null &&
                        reminder.linkedId != null) ...[
                      InkWell(
                        onTap: () => _navigateToLinkedItem(
                          context,
                          ref,
                          reminder.linkedType!,
                          reminder.linkedId!,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getLinkedItemLabel(reminder.linkedType),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Date and time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(reminder.dateTime)} at ${timeFormat.format(reminder.dateTime)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isOverdue
                                        ? colorScheme.error
                                        : isDueToday
                                            ? colorScheme.tertiary
                                            : null,
                                    fontWeight: isOverdue || isDueToday
                                        ? FontWeight.bold
                                        : null,
                                  ),
                        ),
                        if (reminder.isRecurring) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.repeat,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reminder.recurringPattern ?? 'Recurring',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                          ),
                        ],
                      ],
                    ),
                    // Status badges
                    if (isOverdue && !reminder.isCompleted) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'OVERDUE',
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else if (isDueToday && !reminder.isCompleted) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DUE TODAY',
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!reminder.isCompleted && onMarkDone != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: onMarkDone,
                      color: colorScheme.primary,
                      tooltip: 'Mark as Done',
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
