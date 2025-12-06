import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<Either<Failure, List<Note>>> getAllNotes();
  Future<Either<Failure, Note?>> getNoteById(Id id);
  Future<Either<Failure, List<Note>>> getNotesByColor(String color);
  Future<Either<Failure, List<Note>>> searchNotes(String query);
  Future<Either<Failure, Id>> addNote(Note note);
  Future<Either<Failure, bool>> updateNote(Note note);
  Future<Either<Failure, bool>> deleteNote(Id id);
}
