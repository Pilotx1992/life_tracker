import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:life_tracker/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:life_tracker/features/reminders/domain/repositories/reminder_repository.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService.instance);

// Reminder providers
final reminderLocalDataSourceProvider = Provider<ReminderLocalDataSource>(
  (ref) => ReminderLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepositoryImpl(ref.read(reminderLocalDataSourceProvider)),
);
