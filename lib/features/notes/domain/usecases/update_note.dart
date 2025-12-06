import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class UpdateNote implements UseCase<bool, Note> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<Either<Failure, bool>> call(Note params) async {
    return await repository.updateNote(params);
  }
}
