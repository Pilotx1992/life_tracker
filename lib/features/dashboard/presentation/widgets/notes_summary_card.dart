import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/presentation/providers/note_provider.dart';

class NotesSummaryCard extends ConsumerWidget {
  const NotesSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppRoutes.notes),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No notes',
                    'Create your first note to get started',
                    () => context.push(AppRoutes.notes),
                  );
                }

                // Get most recent note
                final sortedNotes = List<Note>.from(notes);
                sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                final recentNote = sortedNotes.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total count
                    _buildTotalCount(context, notes.length),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Recent note
                    _buildRecentNote(context, recentNote),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
            const SizedBox(height: 16),
            // Quick Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.notes),
                icon: const Icon(Icons.add),
                label: const Text('New Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCount(BuildContext context, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.note, color: Colors.purple, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Notes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(
                '$count ${count == 1 ? 'note' : 'notes'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentNote(BuildContext context, Note note) {
    final hasChecklist = note.checklistItems.isNotEmpty;
    final checkedCount =
        note.checklistItems.where((item) => item.isChecked).length;
    final totalChecklist = note.checklistItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.note_outlined,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (note.content != null && note.content!.isNotEmpty)
          Text(
            note.content!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (hasChecklist) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.checklist, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '$checkedCount/$totalChecklist completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Updated ${DateFormat('MMM dd, yyyy').format(note.updatedAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Error: $error',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }
}
