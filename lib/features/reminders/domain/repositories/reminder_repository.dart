import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';

abstract class ReminderRepository {
  Future<Either<Failure, List<Reminder>>> getAllReminders();
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders();
  Future<Either<Failure, List<Reminder>>> getCompletedReminders();
  Future<Either<Failure, List<Reminder>>> getRemindersByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, Reminder?>> getReminderById(Id id);
  Future<Either<Failure, List<Reminder>>> getRemindersByLinkedItem(
    String linkedType,
    Id linkedId,
  );
  Future<Either<Failure, Id>> addReminder(Reminder reminder);
  Future<Either<Failure, bool>> updateReminder(Reminder reminder);
  Future<Either<Failure, bool>> deleteReminder(Id id);
  Future<Either<Failure, bool>> markReminderAsCompleted(Id id);
  Future<Either<Failure, int>> autoCompleteExpiredReminders();
}
