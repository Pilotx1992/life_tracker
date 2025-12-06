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

  @override
  Widget build(BuildContext context) {
    return AppListItem(
      title: Text(
        medication.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dosage: ${medication.dosage}'),
          Text('Times: ${_formatTimes(medication.times)}'),
          // TODO: Show next reminder time
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
