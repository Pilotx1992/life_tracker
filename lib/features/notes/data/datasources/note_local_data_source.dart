import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/notes/data/models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel?> getNoteById(Id id);
  Future<List<NoteModel>> getNotesByColor(String color);
  Future<List<NoteModel>> searchNotes(String query);
  Future<Id> addNote(NoteModel note);
  Future<bool> updateNote(NoteModel note);
  Future<bool> deleteNote(Id id);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final DatabaseService _databaseService;

  NoteLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final isar = await _databaseService.database;
      final notes = await isar.noteModels.where().findAll();
      notes.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      ); // Most recent first
      return notes;
    } catch (e) {
      throw CacheException('Failed to get notes: $e');
    }
  }

  @override
  Future<NoteModel?> getNoteById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.noteModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get note: $e');
    }
  }

  @override
  Future<List<NoteModel>> getNotesByColor(String color) async {
    try {
      final isar = await _databaseService.database;
      final notes =
          await isar.noteModels.filter().colorEqualTo(color).findAll();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    } catch (e) {
      throw CacheException('Failed to get notes by color: $e');
    }
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    try {
      final isar = await _databaseService.database;
      final lowerQuery = query.toLowerCase();
      final allNotes = await isar.noteModels.where().findAll();
      final filtered = allNotes.where((note) {
        return note.title.toLowerCase().contains(lowerQuery) ||
            (note.content != null &&
                note.content!.toLowerCase().contains(lowerQuery));
      }).toList();
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return filtered;
    } catch (e) {
      throw CacheException('Failed to search notes: $e');
    }
  }

  @override
  Future<Id> addNote(NoteModel note) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.noteModels.put(note);
      });
      return note.id;
    } catch (e) {
      throw CacheException('Failed to add note: $e');
    }
  }

  @override
  Future<bool> updateNote(NoteModel note) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        note.updatedAt = DateTime.now();
        await isar.noteModels.put(note);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update note: $e');
    }
  }

  @override
  Future<bool> deleteNote(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.noteModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete note: $e');
    }
  }
}
