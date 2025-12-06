import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/features/notes/data/datasources/note_local_data_source.dart';
import 'package:life_tracker/features/notes/data/repositories/note_repository_impl.dart';
import 'package:life_tracker/features/notes/domain/repositories/note_repository.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService.instance);

// Note providers
final noteLocalDataSourceProvider = Provider<NoteLocalDataSource>(
  (ref) => NoteLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(ref.read(noteLocalDataSourceProvider)),
);
