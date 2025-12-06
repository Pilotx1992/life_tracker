import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class GetNotesByColor implements UseCase<List<Note>, String> {
  final NoteRepository repository;

  GetNotesByColor(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(String color) async {
    return await repository.getNotesByColor(color);
  }
}
