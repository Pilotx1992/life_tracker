import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/presentation/providers/note_provider.dart';
import 'package:life_tracker/features/notes/presentation/widgets/color_picker.dart';
import 'package:life_tracker/features/notes/presentation/widgets/note_card.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/notes/presentation/widgets/note_list_item.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart'
    as error_widget;
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';
import 'package:life_tracker/features/notes/presentation/widgets/pin_input_dialog.dart';
import 'package:life_tracker/features/notes/services/note_encryption_service.dart';

/// Note filter/sort options
enum NoteSortBy { dateNewest, dateOldest, title }

enum NoteDateFilter { all, today, thisWeek, thisMonth }

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _isGridView = true;
  NoteSortBy _sortBy = NoteSortBy.dateNewest;
  String? _selectedColor;
  NoteDateFilter _dateFilter = NoteDateFilter.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedColor != null ||
      _dateFilter != NoteDateFilter.all ||
      _searchQuery.isNotEmpty;

  int get _activeFilterCount {
    int count = 0;
    if (_selectedColor != null) count++;
    if (_dateFilter != NoteDateFilter.all) count++;
    if (_searchQuery.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          // Filter & Sort button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => _showFilterSortSheet(context),
                tooltip: 'Filter & Sort',
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_activeFilterCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Quick Filter Chips
          _buildQuickFilterChips(),

          // Active Filters Display
          if (_hasActiveFilters) _buildActiveFiltersChips(),

          // Notes list/grid
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                final filteredNotes = _applyFiltersAndSort(notes);

                if (filteredNotes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(noteNotifierProvider.notifier).loadNotes(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: EmptyStateWidget(
                          icon: Icons.note,
                          title: _hasActiveFilters
                              ? 'No notes match your filters'
                              : 'No Notes',
                          subtitle: _hasActiveFilters
                              ? null
                              : 'Create your first note to get started',
                          actionLabel:
                              _hasActiveFilters ? 'Clear Filters' : null,
                          onAction: _hasActiveFilters ? _clearAllFilters : null,
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(noteNotifierProvider.notifier).loadNotes(),
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(8),
                          cacheExtent: 500,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return NoteCard(
                              key: ValueKey('note_${note.id}'),
                              note: note,
                              onTap: () => _navigateToEditor(context, note),
                              onDelete: () =>
                                  _showDeleteConfirmation(context, note),
                            );
                          },
                        )
                      : ListView.builder(
                          cacheExtent: 500,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return Dismissible(
                              key: ValueKey('note_${note.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: AlignmentDirectional.centerEnd,
                                padding:
                                    const EdgeInsetsDirectional.only(end: 20),
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
                                        title: const Text('Delete Note'),
                                        content: Text(
                                          'Are you sure you want to delete "${note.title}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              },
                              onDismissed: (direction) {
                                _handleDelete(context, note);
                              },
                              child: NoteListItem(
                                note: note,
                                onTap: () => _navigateToEditor(context, note),
                                onDelete: () =>
                                    _showDeleteConfirmation(context, note),
                              ),
                            );
                          },
                        ),
                );
              },
              loading: () => _isGridView
                  ? const SkeletonGrid(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    )
                  : SkeletonList.cards(itemCount: 6),
              error: (error, stack) =>
                  error_widget.ErrorStateWidget(message: error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Date filter chips
            FilterChip(
              label: const Text('All'),
              selected: _dateFilter == NoteDateFilter.all,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _dateFilter = NoteDateFilter.all);
                }
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.today, size: 16),
              label: const Text('Today'),
              selected: _dateFilter == NoteDateFilter.today,
              onSelected: (selected) {
                setState(() {
                  _dateFilter =
                      selected ? NoteDateFilter.today : NoteDateFilter.all;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.date_range, size: 16),
              label: const Text('This Week'),
              selected: _dateFilter == NoteDateFilter.thisWeek,
              onSelected: (selected) {
                setState(() {
                  _dateFilter =
                      selected ? NoteDateFilter.thisWeek : NoteDateFilter.all;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.calendar_month, size: 16),
              label: const Text('This Month'),
              selected: _dateFilter == NoteDateFilter.thisMonth,
              onSelected: (selected) {
                setState(() {
                  _dateFilter =
                      selected ? NoteDateFilter.thisMonth : NoteDateFilter.all;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];

    // Date filter chip
    if (_dateFilter != NoteDateFilter.all) {
      chips.add(
        Chip(
          label: Text(_getDateFilterLabel(_dateFilter)),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() => _dateFilter = NoteDateFilter.all);
          },
        ),
      );
    }

    // Color filter chip
    if (_selectedColor != null) {
      chips.add(
        Chip(
          avatar: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _hexToColor(_selectedColor!),
              shape: BoxShape.circle,
            ),
          ),
          label: const Text('Color'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() => _selectedColor = null);
          },
        ),
      );
    }

    // Search chip
    if (_searchQuery.isNotEmpty) {
      chips.add(
        Chip(
          avatar: const Icon(Icons.search, size: 16),
          label: Text('"$_searchQuery"'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: chips,
      ),
    );
  }

  String _getDateFilterLabel(NoteDateFilter filter) {
    switch (filter) {
      case NoteDateFilter.all:
        return 'All';
      case NoteDateFilter.today:
        return 'Today';
      case NoteDateFilter.thisWeek:
        return 'This Week';
      case NoteDateFilter.thisMonth:
        return 'This Month';
    }
  }

  List<Note> _applyFiltersAndSort(List<Note> notes) {
    var filtered = notes;

    // Date filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_dateFilter) {
      case NoteDateFilter.all:
        break;
      case NoteDateFilter.today:
        filtered = filtered.where((n) {
          final noteDate = DateTime(
            n.updatedAt.year,
            n.updatedAt.month,
            n.updatedAt.day,
          );
          return noteDate == today;
        }).toList();
        break;
      case NoteDateFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        filtered = filtered.where((n) {
          return n.updatedAt.isAfter(weekStart) ||
              n.updatedAt.isAtSameMomentAs(weekStart);
        }).toList();
        break;
      case NoteDateFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        filtered = filtered.where((n) {
          return n.updatedAt.isAfter(monthStart) ||
              n.updatedAt.isAtSameMomentAs(monthStart);
        }).toList();
        break;
    }

    // Color filter
    if (_selectedColor != null) {
      filtered = filtered.where((n) => n.color == _selectedColor).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(lowerQuery) ||
            (n.content != null &&
                n.content!.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case NoteSortBy.dateNewest:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortBy.dateOldest:
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSortBy.title:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _dateFilter = NoteDateFilter.all;
      _selectedColor = null;
      _searchQuery = '';
    });
  }

  void _showFilterSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      _clearAllFilters();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Sort Options
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  avatar: const Icon(Icons.arrow_downward, size: 16),
                  label: const Text('Newest'),
                  selected: _sortBy == NoteSortBy.dateNewest,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortBy = NoteSortBy.dateNewest);
                      Navigator.pop(context);
                    }
                  },
                ),
                FilterChip(
                  avatar: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text('Oldest'),
                  selected: _sortBy == NoteSortBy.dateOldest,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortBy = NoteSortBy.dateOldest);
                      Navigator.pop(context);
                    }
                  },
                ),
                FilterChip(
                  avatar: const Icon(Icons.sort_by_alpha, size: 16),
                  label: const Text('Title'),
                  selected: _sortBy == NoteSortBy.title,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _sortBy = NoteSortBy.title);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Color Filter
            Text(
              'Filter by Color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Colors'),
                  selected: _selectedColor == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedColor = null);
                      Navigator.pop(context);
                    }
                  },
                ),
                ...ColorPicker.noteColors.map((color) {
                  return FilterChip(
                    avatar: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _hexToColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    label: const Text(''),
                    selected: _selectedColor == color,
                    onSelected: (selected) {
                      setState(() {
                        _selectedColor = selected ? color : null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  void _navigateToEditor(BuildContext context, Note? note) {
    // Use query parameter for note ID to survive Activity recreation
    final path = note?.id != null
        ? '${AppRoutes.noteEditor}?id=${note!.id}'
        : AppRoutes.noteEditor;
    context.push(path, extra: note);
  }

  Future<void> _handleDelete(BuildContext context, Note note) async {
    if (note.id == null) return;

    // If note is locked, verify PIN before deleting
    if (note.isLocked) {
      final verified = await _verifyPINForDelete(context);
      if (!verified) {
        // Reload notes to restore the dismissed item
        ref.read(noteNotifierProvider.notifier).loadNotes();
        return;
      }
    }

    if (!context.mounted) return;
    _deleteNote(context, note);
  }

  Future<bool> _verifyPINForDelete(BuildContext context) async {
    final encryptionService = NoteEncryptionService();
    final hasPIN = await encryptionService.hasPIN();

    if (!hasPIN) {
      // No PIN set, allow delete
      return true;
    }

    if (!context.mounted) return false;

    // Show PIN dialog
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PINInputDialog(
        title: 'Delete Locked Note',
        message: 'Enter your PIN to delete this locked note',
      ),
    );

    if (pin == null) {
      if (context.mounted) {
        FeedbackService.showInfo(context, 'Delete cancelled');
      }
      return false;
    }

    // Verify PIN
    final isValid = await encryptionService.verifyPIN(pin);
    if (!isValid) {
      if (context.mounted) {
        FeedbackService.showError(context, 'Incorrect PIN');
      }
      return false;
    }

    return true;
  }

  void _deleteNote(BuildContext context, Note note) {
    if (note.id == null) return;

    ref.read(noteNotifierProvider.notifier).deleteNoteEntry(note.id!);
    FeedbackService.showSuccess(context, '"${note.title}" deleted');
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
          'Are you sure you want to delete "${note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleDelete(context, note);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
