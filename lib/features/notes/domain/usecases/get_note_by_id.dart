import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class GetNoteById implements UseCase<Note?, Id> {
  final NoteRepository repository;

  GetNoteById(this.repository);

  @override
  Future<Either<Failure, Note?>> call(Id params) async {
    return await repository.getNoteById(params);
  }
}
