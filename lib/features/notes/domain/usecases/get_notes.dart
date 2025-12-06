import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class GetNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository repository;

  GetNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) async {
    return await repository.getAllNotes();
  }
}
