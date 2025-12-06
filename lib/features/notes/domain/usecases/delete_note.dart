import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class DeleteNote implements UseCase<bool, Id> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, bool>> call(Id params) async {
    return await repository.deleteNote(params);
  }
}
