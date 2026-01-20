import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/notes/domain/entities/checklist_item.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/presentation/providers/note_provider.dart';
import 'package:life_tracker/features/notes/presentation/widgets/attachment_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/audio_player_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/checklist_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/color_picker.dart';
import 'package:life_tracker/features/notes/presentation/widgets/voice_recorder_widget.dart';
import 'package:life_tracker/features/notes/services/attachment_service.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/presentation/widgets/add_reminder_dialog.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final int? noteId; // Used when Activity is recreated

  const NoteEditorScreen({super.key, this.note, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedColor = '#FFFFFF';
  List<ChecklistItem> _checklistItems = [];
  List<String> _attachmentPaths = [];
  String? _voiceNotePath;
  String? _voiceNoteName;
  final AttachmentService _attachmentService = AttachmentService();
  bool _hasChanges = false;
  Note? _loadedNote; // Note loaded by ID
  bool _isLoading = false;
  bool _isInitialized = false; // Track if note data was loaded

  Note? get _effectiveNote => widget.note ?? _loadedNote;

  @override
  void initState() {
    super.initState();
    // Only populate from widget.note in initState (no ref access)
    if (widget.note != null) {
      _populateFromNote(widget.note!);
      _isInitialized = true;
    }
    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load note by ID here (where ref is safe to use)
    // Use post frame callback to avoid calling async methods during build
    if (!_isInitialized && widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isInitialized) {
          _loadNoteById();
        }
      });
    }
  }

  Future<void> _loadNoteById() async {
    if (_isInitialized) return;

    setState(() => _isLoading = true);
    try {
      final notes = ref.read(noteNotifierProvider).valueOrNull ?? [];
      final note = notes.firstWhere(
        (n) => n.id == widget.noteId,
        orElse: () => throw Exception('Note not found'),
      );
      _loadedNote = note;
      _populateFromNote(note);
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading note by ID: $e');
      _isInitialized = true; // Mark as initialized even on error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateFromNote(Note note) {
    _titleController.text = note.title;
    _contentController.text = note.content ?? '';
    _selectedColor = note.color;
    _checklistItems = List<ChecklistItem>.from(note.checklistItems);
    _attachmentPaths = List<String>.from(note.attachmentPaths);
    _voiceNotePath = note.voiceNotePath;
    _voiceNoteName = note.voiceNoteName;

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final note = Note(
        id: _effectiveNote?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isEmpty
            ? null
            : _contentController.text.trim(),
        color: _selectedColor,
        attachmentPaths: _attachmentPaths,
        voiceNotePath: _voiceNotePath,
        voiceNoteName: _voiceNoteName,
        checklistItems: _checklistItems,
        createdAt: _effectiveNote?.createdAt ?? now,
        updatedAt: now,
      );

      if (_effectiveNote == null) {
        await ref.read(noteNotifierProvider.notifier).addNoteEntry(note);
      } else {
        await ref.read(noteNotifierProvider.notifier).updateNoteEntry(note);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading note by ID
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );

        if (shouldPop == true) {
          if (mounted) {
            // Allow popping now
            setState(() {
              _hasChanges = false;
            });
            // We need to wait for the rebuild to complete so PopScope sees canPop: true
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_effectiveNote == null ? 'New Note' : 'Edit Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Save',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Note title',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Content
                AppTextField(
                  controller: _contentController,
                  label: 'Content',
                  hint: 'Note content',
                  maxLines: 10,
                ),
                const SizedBox(height: 24),
                // Color Picker
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ColorPicker(
                  selectedColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      _selectedColor = color;
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Checklist
                Text(
                  'Checklist',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ChecklistWidget(
                  items: _checklistItems,
                  onItemChanged: (index, item) {
                    setState(() {
                      _checklistItems[index] = item;
                      _hasChanges = true;
                    });
                  },
                  onItemDeleted: (index) {
                    setState(() {
                      _checklistItems.removeAt(index);
                      _hasChanges = true;
                    });
                  },
                  onAddItem: () {
                    setState(() {
                      _checklistItems.add(const ChecklistItem(text: ''));
                      _hasChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Attachments Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attachments',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () => _addImage(context),
                          tooltip: 'Add Image',
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () => _addFile(context),
                          tooltip: 'Add File',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Display attachments
                if (_attachmentPaths.isNotEmpty) ...[
                  ..._attachmentPaths.map((path) {
                    return AttachmentWidget(
                      attachmentPath: path,
                      onDelete: () => _removeAttachment(path),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
                // Voice Note Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voice Note',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_voiceNotePath == null)
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () => _recordVoiceNote(context),
                        tooltip: 'Record Voice Note',
                      ),
                  ],
                ),
                if (_voiceNotePath != null) ...[
                  const SizedBox(height: 8),
                  AudioPlayerWidget(
                    audioPath: _voiceNotePath!,
                    displayName: _voiceNoteName,
                    attachmentService: _attachmentService,
                    onDelete: _removeVoiceNote,
                  ),
                ],
                const SizedBox(height: 24),
                // Link to Reminder (only for existing notes)
                if (_effectiveNote != null && _effectiveNote!.id != null) ...[
                  Text(
                    'Reminder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Create Reminder'),
                      subtitle: const Text('Link this note to a reminder'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _createReminderFromNote(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createReminderFromNote(BuildContext context) async {
    if (_effectiveNote == null || _effectiveNote!.id == null) return;

    // Show dialog to create reminder
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        reminder: Reminder(
          title: _effectiveNote!.title,
          description: _effectiveNote!.content,
          dateTime: DateTime.now().add(const Duration(hours: 1)),
          linkedType: 'note',
          linkedId: _effectiveNote!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _addImage(BuildContext context) async {
    final path = await _attachmentService.pickImageWithSource(context);
    if (!mounted) return;
    if (path != null) {
      setState(() {
        _attachmentPaths.add(path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _addFile(BuildContext context) async {
    final path = await _attachmentService.pickFile();
    if (!mounted) return;
    if (path != null) {
      setState(() {
        _attachmentPaths.add(path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _removeAttachment(String path) async {
    setState(() {
      _attachmentPaths.remove(path);
      _hasChanges = true;
    });
    // Delete file from storage
    try {
      await _attachmentService.deleteAttachment(path);
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting attachment: $e');
      // State already updated, so continue
    }
  }

  Future<void> _recordVoiceNote(BuildContext context) async {
    // Import and use the voice recorder bottom sheet
    final result = await showVoiceRecorderSheet(context);

    if (result == null || !mounted) return;

    final name = result.name ?? 'Voice note';

    setState(() {
      _voiceNotePath = result.path;
      _voiceNoteName = result.name;
      _hasChanges = true;
    });

    // Check mounted again after setState before using context
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    FeedbackService.showSuccess(context, '$name saved successfully');
  }

  Future<void> _removeVoiceNote() async {
    if (_voiceNotePath == null) return;

    final pathToDelete = _voiceNotePath!;
    if (kDebugMode) {
      debugPrint('Attempting to delete voice note: $pathToDelete');
    }

    try {
      // Delete the file first
      final deleted = await _attachmentService.deleteAttachment(pathToDelete);
      if (kDebugMode) debugPrint('Voice note deletion result: $deleted');

      if (!mounted) return;

      // Always clear the state, regardless of deletion result
      setState(() {
        _voiceNotePath = null;
        _voiceNoteName = null;
        _hasChanges = true;
      });

      if (deleted) {
        FeedbackService.showSuccess(context, 'Voice note deleted');
      } else {
        // File might not exist, but we still cleared the state
        if (kDebugMode) {
          debugPrint(
            'Voice note file not found or already deleted: $pathToDelete',
          );
        }
        FeedbackService.showInfo(context, 'Voice note removed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error deleting voice note: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      if (!mounted) return;

      // Even if deletion fails, clear the state
      setState(() {
        _voiceNotePath = null;
        _voiceNoteName = null;
        _hasChanges = true;
      });

      FeedbackService.showError(
        context,
        'Failed to delete voice note: ${e.toString()}',
      );
    }
  }
}
