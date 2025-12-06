import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/notes/data/datasources/note_local_data_source.dart';
import 'package:life_tracker/features/notes/data/models/note_model.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Note>>> getAllNotes() async {
    try {
      final noteModels = await localDataSource.getAllNotes();
      final notes = noteModels.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Note?>> getNoteById(Id id) async {
    try {
      final noteModel = await localDataSource.getNoteById(id);
      return Right(noteModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getNotesByColor(String color) async {
    try {
      final noteModels = await localDataSource.getNotesByColor(color);
      final notes = noteModels.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> searchNotes(String query) async {
    try {
      final noteModels = await localDataSource.searchNotes(query);
      final notes = noteModels.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final id = await localDataSource.addNote(noteModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final success = await localDataSource.updateNote(noteModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNote(Id id) async {
    try {
      final success = await localDataSource.deleteNote(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
