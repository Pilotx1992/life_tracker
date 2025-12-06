import 'package:flutter/material.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/shared/widgets/app_list_item.dart';

class WeightListItem extends StatelessWidget {
  final WeightEntry weightEntry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WeightListItem({
    super.key,
    required this.weightEntry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppListItem(
      title: Text(
        '${weightEntry.weight.toStringAsFixed(1)} kg',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        '${weightEntry.date.toLocal().toString().split(' ')[0]} ${weightEntry.note != null ? ' - ${weightEntry.note}' : ''}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Entry',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Entry',
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
