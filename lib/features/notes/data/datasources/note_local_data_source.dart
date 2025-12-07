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
      // Use Isar's built-in sorting for better performance
      return await isar.noteModels
          .where()
          .sortByUpdatedAtDesc()
          .findAll();
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
      // Use Isar's built-in sorting for better performance
      return await isar.noteModels
          .filter()
          .colorEqualTo(color)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get notes by color: $e');
    }
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    try {
      final isar = await _databaseService.database;
      final lowerQuery = query.toLowerCase();
      // Get all notes sorted by updatedAt (most recent first)
      final allNotes = await isar.noteModels
          .where()
          .sortByUpdatedAtDesc()
          .findAll();
      // Filter in memory (Isar doesn't support case-insensitive text search)
      return allNotes.where((note) {
        return note.title.toLowerCase().contains(lowerQuery) ||
            (note.content != null &&
                note.content!.toLowerCase().contains(lowerQuery));
      }).toList();
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
