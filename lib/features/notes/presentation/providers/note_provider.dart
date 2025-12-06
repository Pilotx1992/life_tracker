import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/usecases/add_note.dart';
import 'package:life_tracker/features/notes/domain/usecases/delete_note.dart';
import 'package:life_tracker/features/notes/domain/usecases/get_note_by_id.dart';
import 'package:life_tracker/features/notes/domain/usecases/get_notes.dart';
import 'package:life_tracker/features/notes/domain/usecases/get_notes_by_color.dart';
import 'package:life_tracker/features/notes/domain/usecases/search_notes.dart';
import 'package:life_tracker/features/notes/domain/usecases/update_note.dart';
import 'package:life_tracker/features/notes/notes_providers.dart';
import 'package:life_tracker/features/notes/services/attachment_service.dart';
import 'package:life_tracker/features/reminders/services/linked_reminder_service.dart';

// Providers for use cases (dependency injection)
final addNoteUseCaseProvider =
    Provider((ref) => AddNote(ref.read(noteRepositoryProvider)));
final getNotesUseCaseProvider =
    Provider((ref) => GetNotes(ref.read(noteRepositoryProvider)));
final getNoteByIdUseCaseProvider =
    Provider((ref) => GetNoteById(ref.read(noteRepositoryProvider)));
final getNotesByColorUseCaseProvider =
    Provider((ref) => GetNotesByColor(ref.read(noteRepositoryProvider)));
final searchNotesUseCaseProvider =
    Provider((ref) => SearchNotes(ref.read(noteRepositoryProvider)));
final updateNoteUseCaseProvider =
    Provider((ref) => UpdateNote(ref.read(noteRepositoryProvider)));
final deleteNoteUseCaseProvider =
    Provider((ref) => DeleteNote(ref.read(noteRepositoryProvider)));

// StateNotifier for managing note-related state
class NoteNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final AddNote _addNote;
  final GetNotes _getNotes;
  final GetNoteById _getNoteById;
  final GetNotesByColor _getNotesByColor;
  final SearchNotes _searchNotes;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;
  final AttachmentService _attachmentService = AttachmentService();
  final LinkedReminderService? _linkedReminderService;

  NoteNotifier({
    required AddNote addNote,
    required GetNotes getNotes,
    required GetNoteById getNoteById,
    required GetNotesByColor getNotesByColor,
    required SearchNotes searchNotes,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
    LinkedReminderService? linkedReminderService,
  })  : _addNote = addNote,
        _getNotes = getNotes,
        _getNoteById = getNoteById,
        _getNotesByColor = getNotesByColor,
        _searchNotes = searchNotes,
        _updateNote = updateNote,
        _deleteNote = deleteNote,
        _linkedReminderService = linkedReminderService,
        super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    final result = await _getNotes(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (notes) => AsyncValue.data(notes),
    );
  }

  Future<Note?> getNoteById(Id id) async {
    final result = await _getNoteById(id);
    return result.fold(
      (failure) => null,
      (note) => note,
    );
  }

  Future<List<Note>> getNotesByColor(String color) async {
    final result = await _getNotesByColor(color);
    return result.fold(
      (failure) => <Note>[],
      (notes) => notes,
    );
  }

  Future<List<Note>> searchNotes(String query) async {
    final result = await _searchNotes(query);
    return result.fold(
      (failure) => <Note>[],
      (notes) => notes,
    );
  }

  Future<void> addNoteEntry(Note note) async {
    final result = await _addNote(note);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) => loadNotes(), // Reload notes after adding
    );
  }

  Future<void> updateNoteEntry(Note note) async {
    final result = await _updateNote(note);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadNotes(), // Reload notes after updating
    );
  }

  Future<void> deleteNoteEntry(Id id) async {
    // Get note first to delete attachments
    final note = await getNoteById(id);
    if (note != null) {
      // Delete all attachments
      if (note.attachmentPaths.isNotEmpty) {
        await _attachmentService.deleteAttachments(note.attachmentPaths);
      }
      // Delete voice note
      if (note.voiceNotePath != null) {
        await _attachmentService.deleteAttachment(note.voiceNotePath!);
      }
      // Delete linked reminders
      if (_linkedReminderService != null && note.id != null) {
        await _linkedReminderService.deleteLinkedReminders('note', note.id!);
      }
    }

    final result = await _deleteNote(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadNotes(), // Reload notes after deleting
    );
  }
}

final noteNotifierProvider =
    StateNotifierProvider<NoteNotifier, AsyncValue<List<Note>>>((ref) {
  return NoteNotifier(
    addNote: ref.read(addNoteUseCaseProvider),
    getNotes: ref.read(getNotesUseCaseProvider),
    getNoteById: ref.read(getNoteByIdUseCaseProvider),
    getNotesByColor: ref.read(getNotesByColorUseCaseProvider),
    searchNotes: ref.read(searchNotesUseCaseProvider),
    updateNote: ref.read(updateNoteUseCaseProvider),
    deleteNote: ref.read(deleteNoteUseCaseProvider),
  );
});
