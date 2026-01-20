import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/entities/checklist_item.dart';
import 'package:life_tracker/features/notes/presentation/providers/note_provider.dart';
import 'package:life_tracker/features/notes/presentation/widgets/attachment_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/audio_player_widget.dart';
import 'package:life_tracker/features/notes/services/attachment_service.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final attachmentService = AttachmentService();

    // Parse color
    final color = Color(int.parse(widget.note.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        backgroundColor: color.withValues(alpha: 0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Note',
            onPressed: () => _editNote(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Note',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 88), // Space for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDesignTokens.space24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.note.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Metadata
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updated ${dateFormat.format(widget.note.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            if (widget.note.content != null && widget.note.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.note.content!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

            // Checklist
            if (widget.note.checklistItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Todo List',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _addChecklistItem(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDesignTokens.space12),
                        child: Column(
                          children: widget.note.checklistItems
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: item.isChecked,
                                    onChanged: (value) =>
                                        _toggleChecklistItem(index),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.text,
                                      style: TextStyle(
                                        decoration: item.isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isChecked
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _deleteChecklistItem(index),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Add Todo List Button (if no checklist exists)
            if (widget.note.checklistItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: OutlinedButton.icon(
                  onPressed: () => _addChecklistItem(context),
                  icon: const Icon(Icons.checklist),
                  label: const Text('Add Todo List'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

            // Attachments
            if (widget.note.attachmentPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.note.attachmentPaths.map((path) {
                      return AttachmentWidget(
                        attachmentPath: path,
                        onDelete: null, // Read-only in detail view
                      );
                    }),
                  ],
                ),
              ),

            // Voice Note
            if (widget.note.voiceNotePath != null)
              Padding(
                padding: const EdgeInsets.all(AppDesignTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Note',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    AudioPlayerWidget(
                      audioPath: widget.note.voiceNotePath!,
                      displayName: widget.note.voiceNoteName,
                      attachmentService: attachmentService,
                      onDelete: null, // Read-only in detail view
                    ),
                  ],
                ),
              ),

            // Metadata Card
            Padding(
              padding: const EdgeInsets.all(AppDesignTokens.space16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDesignTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note Information',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Created',
                        dateFormat.format(widget.note.createdAt),
                        Icons.add_circle_outline,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Last Updated',
                        dateFormat.format(widget.note.updatedAt),
                        Icons.update,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Status',
                        'Active',
                        Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editNote(context),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editNote(BuildContext context) {
    context.push(
      AppRoutes.noteEditor,
      extra: widget.note,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content:
            Text('Are you sure you want to delete "${widget.note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(noteNotifierProvider.notifier)
          .deleteNoteEntry(widget.note.id!);

      if (!context.mounted) return;

      Navigator.of(context).pop();
      FeedbackService.showSuccess(context, 'Note deleted');
    }
  }

  /// Add a new checklist item
  Future<void> _addChecklistItem(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter todo item...',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newItem = ChecklistItem(text: result, isChecked: false);
      final updatedItems = [...widget.note.checklistItems, newItem];
      final updatedNote = widget.note.copyWith(
        checklistItems: updatedItems,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(noteNotifierProvider.notifier)
          .updateNoteEntry(updatedNote);
      if (context.mounted) {
        FeedbackService.showSuccess(context, 'Todo item added');
      }
    }
  }

  /// Toggle a checklist item's checked state
  Future<void> _toggleChecklistItem(int index) async {
    final items = List<ChecklistItem>.from(widget.note.checklistItems);
    items[index] = items[index].copyWith(isChecked: !items[index].isChecked);

    final updatedNote = widget.note.copyWith(
      checklistItems: items,
      updatedAt: DateTime.now(),
    );

    await ref.read(noteNotifierProvider.notifier).updateNoteEntry(updatedNote);
  }

  /// Delete a checklist item
  Future<void> _deleteChecklistItem(int index) async {
    final items = List<ChecklistItem>.from(widget.note.checklistItems);
    items.removeAt(index);

    final updatedNote = widget.note.copyWith(
      checklistItems: items,
      updatedAt: DateTime.now(),
    );

    await ref.read(noteNotifierProvider.notifier).updateNoteEntry(updatedNote);
    if (mounted) {
      FeedbackService.showSuccess(context, 'Todo item deleted');
    }
  }
}
