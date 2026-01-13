import 'package:flutter/material.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/shared/widgets/app_list_item.dart';

class MedicationListItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicationListItem({
    super.key,
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTimes(List<DateTime> times) {
    if (times.isEmpty) return 'No times set';
    return times
        .map(
          (time) =>
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        )
        .join(', ');
  }

  /// Calculate the next reminder time based on medication schedule
  String? _getNextReminderText() {
    if (medication.times.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if medication is still active
    if (medication.endDate != null && medication.endDate!.isBefore(today)) {
      return null; // Medication ended
    }

    // Find the next scheduled time today or tomorrow
    DateTime? nextReminder;

    for (final time in medication.times) {
      // Create today's reminder time
      final todayReminder = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (todayReminder.isAfter(now)) {
        // This time is still ahead today
        if (nextReminder == null || todayReminder.isBefore(nextReminder)) {
          nextReminder = todayReminder;
        }
      }
    }

    // If no reminder found for today, find first reminder tomorrow
    if (nextReminder == null && medication.times.isNotEmpty) {
      // Sort times to find earliest
      final sortedTimes = List<DateTime>.from(medication.times)
        ..sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });

      final earliestTime = sortedTimes.first;
      final tomorrow = today.add(const Duration(days: 1));
      nextReminder = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        earliestTime.hour,
        earliestTime.minute,
      );
    }

    if (nextReminder == null) return null;

    // Format the reminder text
    final isToday = nextReminder.day == now.day &&
        nextReminder.month == now.month &&
        nextReminder.year == now.year;

    final timeStr =
        '${nextReminder.hour.toString().padLeft(2, '0')}:${nextReminder.minute.toString().padLeft(2, '0')}';

    if (isToday) {
      // Calculate time until reminder
      final diff = nextReminder.difference(now);
      if (diff.inMinutes < 60) {
        return 'Next: in ${diff.inMinutes} min';
      } else {
        return 'Next: Today $timeStr';
      }
    } else {
      return 'Next: Tomorrow $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextReminder = _getNextReminderText();

    return AppListItem(
      title: Text(
        medication.name,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dosage: ${medication.dosage}'),
          Text('Times: ${_formatTimes(medication.times)}'),
          if (nextReminder != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.alarm,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    nextReminder,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Medication',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Medication',
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
