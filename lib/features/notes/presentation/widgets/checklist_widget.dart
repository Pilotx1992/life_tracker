import 'package:flutter/material.dart';
import 'package:life_tracker/features/notes/domain/entities/checklist_item.dart';

class ChecklistWidget extends StatelessWidget {
  final List<ChecklistItem> items;
  final Function(int, ChecklistItem) onItemChanged;
  final Function(int) onItemDeleted;
  final Function() onAddItem;

  const ChecklistWidget({
    super.key,
    required this.items,
    required this.onItemChanged,
    required this.onItemDeleted,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onAddItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Checklist Item'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _ChecklistItemWidget(
            item: item,
            onChanged: (updatedItem) => onItemChanged(index, updatedItem),
            onDeleted: () => onItemDeleted(index),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAddItem,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Item'),
        ),
      ],
    );
  }
}

class _ChecklistItemWidget extends StatefulWidget {
  final ChecklistItem item;
  final Function(ChecklistItem) onChanged;
  final VoidCallback onDeleted;

  const _ChecklistItemWidget({
    required this.item,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  State<_ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<_ChecklistItemWidget> {
  late TextEditingController _controller;
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
    _isChecked = widget.item.isChecked;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) {
            setState(() {
              _isChecked = value ?? false;
            });
            widget.onChanged(widget.item.copyWith(isChecked: _isChecked));
          },
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Checklist item',
              border: InputBorder.none,
              isDense: true,
            ),
            style: TextStyle(
              decoration: _isChecked ? TextDecoration.lineThrough : null,
              color: _isChecked
                  ? Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)
                  : null,
            ),
            onChanged: (value) {
              widget.onChanged(widget.item.copyWith(text: value));
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: widget.onDeleted,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}
