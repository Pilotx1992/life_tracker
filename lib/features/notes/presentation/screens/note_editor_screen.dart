import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/notes/domain/entities/checklist_item.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/presentation/providers/note_provider.dart';
import 'package:life_tracker/features/notes/presentation/widgets/attachment_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/audio_player_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/checklist_widget.dart';
import 'package:life_tracker/features/notes/presentation/widgets/color_picker.dart';
import 'package:life_tracker/features/notes/presentation/widgets/pin_input_dialog.dart';
import 'package:life_tracker/features/notes/presentation/widgets/voice_recorder_widget.dart';
import 'package:life_tracker/features/notes/services/attachment_service.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/notes/services/note_encryption_service.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/presentation/widgets/add_reminder_dialog.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

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
  String? _encryptedContent;
  final AttachmentService _attachmentService = AttachmentService();
  final NoteEncryptionService _encryptionService = NoteEncryptionService();
  bool _hasChanges = false;
  bool _isUnlocked = true; // Track if locked note is currently unlocked

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      final note = widget.note!;
      _titleController.text = note.title;
      _contentController.text = note.content ?? '';
      _selectedColor = note.color;
      _checklistItems = List<ChecklistItem>.from(note.checklistItems);
      _attachmentPaths = List<String>.from(note.attachmentPaths);
      _voiceNotePath = note.voiceNotePath;
      _encryptedContent = note.encryptedContent;

      // If note is locked, require PIN to unlock
      if (note.isLocked && note.encryptedContent != null) {
        _isUnlocked = false;
        _contentController.text = ''; // Don't show content until unlocked
      }
    }

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

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      // When saving a locked note, content should be null and encryptedContent should be set
      // When saving an unlocked note, content should be set and encryptedContent should be null
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: _encryptedContent != null
            ? null
            : (_contentController.text.trim().isEmpty
                ? null
                : _contentController.text.trim()),
        encryptedContent: _encryptedContent,
        color: _selectedColor,
        attachmentPaths: _attachmentPaths,
        voiceNotePath: _voiceNotePath,
        checklistItems: _checklistItems,
        isLocked: _encryptedContent != null,
        createdAt: widget.note?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.note == null) {
        ref.read(noteNotifierProvider.notifier).addNoteEntry(note);
      } else {
        ref.read(noteNotifierProvider.notifier).updateNoteEntry(note);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to unlock the note
    if (widget.note != null && widget.note!.isLocked && !_isUnlocked) {
      _unlockNote(context);
    }
  }

  Future<void> _unlockNote(BuildContext context) async {
    // Check if PIN is set
    final hasPIN = await _encryptionService.hasPIN();
    if (!context.mounted) return;
    if (!hasPIN) {
      // First time - set up PIN
      final pin = await showDialog<String>(
        context: context,
        builder: (dialogContext) => const PINInputDialog(
          title: 'Set PIN for Note Locking',
          message: 'Create a 4-digit PIN to lock your notes',
          isSetup: true,
        ),
      );
      if (!context.mounted) return;

      if (pin != null) {
        final success = await _encryptionService.setPIN(pin);
        if (!context.mounted) return;
        if (success) {
          await _decryptNoteContent(pin);
        } else {
          FeedbackService.showError(context, 'Failed to set PIN');
          Navigator.of(context).pop();
          return;
        }
      } else {
        if (context.mounted) Navigator.of(context).pop();
        return;
      }
    } else {
      // PIN exists - verify it
      final pin = await showDialog<String>(
        context: context,
        builder: (dialogContext) => const PINInputDialog(
          title: 'Unlock Note',
          message: 'Enter your PIN to unlock this note',
        ),
      );

      if (!context.mounted) return;

      if (pin != null) {
        final isValid = await _encryptionService.verifyPIN(pin);
        if (!context.mounted) return;
        if (isValid) {
          await _decryptNoteContent(pin);
        } else {
          FeedbackService.showError(context, 'Incorrect PIN');
          Navigator.of(context).pop();
          return;
        }
      } else {
        Navigator.of(context).pop();
        return;
      }
    }
  }

  Future<void> _decryptNoteContent(String pin) async {
    if (widget.note?.encryptedContent != null) {
      final decrypted = await _encryptionService.decryptContent(
        widget.note!.encryptedContent!,
        pin,
      );
      if (!mounted) return;
      if (decrypted != null) {
        setState(() {
          _contentController.text = decrypted;
          _isUnlocked = true;
        });
      }
    }
  }

  Future<void> _lockNote() async {
    if (_contentController.text.trim().isEmpty) {
      FeedbackService.showWarning(context, 'Note has no content to lock');
      return;
    }

    // Check if PIN is set
    final hasPIN = await _encryptionService.hasPIN();
    if (!mounted) return;
    String? pin;

    if (!hasPIN) {
      // Set up PIN first
      pin = await showDialog<String>(
        context: context,
        builder: (context) => const PINInputDialog(
          title: 'Set PIN for Note Locking',
          message: 'Create a 4-digit PIN to lock your notes',
          isSetup: true,
        ),
      );

      if (pin == null) return;
      if (!mounted) return;

      final success = await _encryptionService.setPIN(pin);
      if (!mounted) return;
      if (!success) {
        FeedbackService.showError(context, 'Failed to set PIN');
        return;
      }
    } else {
      // Verify PIN
      pin = await showDialog<String>(
        context: context,
        builder: (context) => const PINInputDialog(
          title: 'Lock Note',
          message: 'Enter your PIN to lock this note',
        ),
      );

      if (pin == null) return;
      if (!mounted) return;

      final isValid = await _encryptionService.verifyPIN(pin);
      if (!mounted) return;
      if (!isValid) {
        FeedbackService.showError(context, 'Incorrect PIN');
        return;
      }
    }

    // Encrypt content
    final encrypted = await _encryptionService.encryptContent(
      _contentController.text.trim(),
      pin,
    );

    if (!mounted) return;

    if (encrypted != null) {
      setState(() {
        _encryptedContent = encrypted;
        _contentController.text = ''; // Clear visible content
        _isUnlocked = false;
        _hasChanges = true;
      });
    }
  }

  Future<void> _unlockNoteForEditing() async {
    await _unlockNote(context);
  }

  @override
  Widget build(BuildContext context) {
    // If note is locked and not unlocked, show lock screen
    if (widget.note != null && widget.note!.isLocked && !_isUnlocked) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Note' : 'Locked Note'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'This note is locked',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _unlockNoteForEditing(),
                child: const Text('Unlock Note'),
              ),
            ],
          ),
        ),
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
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          actions: [
            // Lock/Unlock button
            if (widget.note != null)
              IconButton(
                icon: Icon(
                  widget.note!.isLocked && _isUnlocked
                      ? Icons.lock_open
                      : widget.note!.isLocked
                          ? Icons.lock
                          : Icons.lock_outline,
                ),
                onPressed: widget.note!.isLocked && _isUnlocked
                    ? _lockNote
                    : widget.note!.isLocked
                        ? _unlockNoteForEditing
                        : _lockNote,
                tooltip: widget.note!.isLocked && _isUnlocked
                    ? 'Lock Note'
                    : widget.note!.isLocked
                        ? 'Unlock Note'
                        : 'Lock Note',
              ),
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
                  hint: widget.note?.isLocked == true && !_isUnlocked
                      ? 'Note is locked'
                      : 'Note content',
                  maxLines: 10,
                  enabled: !(widget.note?.isLocked == true && !_isUnlocked),
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
                    attachmentService: _attachmentService,
                    onDelete: _removeVoiceNote,
                  ),
                ],
                const SizedBox(height: 24),
                // Link to Reminder (only for existing notes)
                if (widget.note != null && widget.note!.id != null) ...[
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
    if (widget.note == null || widget.note!.id == null) return;

    // Show dialog to create reminder
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        reminder: Reminder(
          title: widget.note!.title,
          description: widget.note!.content,
          dateTime: DateTime.now().add(const Duration(hours: 1)),
          linkedType: 'note',
          linkedId: widget.note!.id,
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

  void _removeAttachment(String path) {
    setState(() {
      _attachmentPaths.remove(path);
      _hasChanges = true;
    });
    // Delete file from storage
    _attachmentService.deleteAttachment(path);
  }

  Future<void> _recordVoiceNote(BuildContext context) async {
    // Import and use the voice recorder bottom sheet
    final result = await showVoiceRecorderSheet(context);

    if (result != null && mounted) {
      setState(() {
        _voiceNotePath = result.path;
        _hasChanges = true;
      });
      if (mounted) {
        final name = result.name ?? 'Voice note';
        FeedbackService.showSuccess(context, '$name saved successfully');
      }
    }
  }

  void _removeVoiceNote() {
    if (_voiceNotePath != null) {
      _attachmentService.deleteAttachment(_voiceNotePath!);
      setState(() {
        _voiceNotePath = null;
        _hasChanges = true;
      });
    }
  }
}
