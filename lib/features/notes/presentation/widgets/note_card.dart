import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteCard({
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
    final checklistProgress = note.checklistProgress;

    return Card(
      color: color,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          // Show delete option on long press
          _showDeleteOption(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Content
              if (note.isLocked)
                Expanded(
                  child: Text(
                    '🔒 Locked',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                )
              else if (note.content != null && note.content!.isNotEmpty)
                Expanded(
                  child: Text(
                    note.content!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 5,
                    overflow: TextOverflow.fade,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(height: 8),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Text(
                    dateFormat.format(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                  ),
                  // Icons
                  Row(
                    children: [
                      if (note.isLocked) const Icon(Icons.lock, size: 14),
                      if (note.voiceNotePath != null)
                        const Icon(Icons.mic, size: 14),
                      if (note.attachmentPaths.isNotEmpty)
                        const Icon(Icons.attach_file, size: 14),
                      if (hasChecklist) ...[
                        const SizedBox(width: 4),
                        Icon(
                          note.isChecklistComplete
                              ? Icons.check_circle
                              : Icons.checklist,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Checklist Progress
              if (hasChecklist && !note.isChecklistComplete) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: checklistProgress,
                  minHeight: 2,
                  backgroundColor: Colors.black.withValues(alpha: 0.1),
                ),
              ],
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
