import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
  });

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final color = _hexToColor(note.color);
    final hasChecklist = note.hasChecklist;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          // Show delete option on long press
          _showDeleteOption(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
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
                    Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Content preview
                    if (note.isLocked)
                      Text(
                        '🔒 Locked',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      )
                    else if (note.content != null && note.content!.isNotEmpty)
                      Text(
                        note.content!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    // Footer
                    Row(
                      children: [
                        Text(
                          dateFormat.format(note.updatedAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                        const SizedBox(width: 8),
                        // Icons
                        if (note.isLocked)
                          Icon(
                            Icons.lock,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        if (note.voiceNotePath != null)
                          Icon(
                            Icons.mic,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        if (note.attachmentPaths.isNotEmpty)
                          Icon(
                            Icons.attach_file,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        if (hasChecklist) ...[
                          const SizedBox(width: 4),
                          Icon(
                            note.isChecklistComplete
                                ? Icons.check_circle
                                : Icons.checklist,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Note'),
              onTap: () {
                Navigator.of(context).pop();
                if (onDelete != null) {
                  onDelete!();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
