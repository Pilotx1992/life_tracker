import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

class SearchNotes implements UseCase<List<Note>, String> {
  final NoteRepository repository;

  SearchNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(String query) async {
    return await repository.searchNotes(query);
  }
}
