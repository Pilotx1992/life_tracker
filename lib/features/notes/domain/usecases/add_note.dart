import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class AddNote implements UseCase<Id, Note> {
  final NoteRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, Id>> call(Note params) async {
    return await repository.addNote(params);
  }
}
