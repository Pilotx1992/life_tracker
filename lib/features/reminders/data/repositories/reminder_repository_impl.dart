import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:life_tracker/features/reminders/data/models/reminder_model.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Reminder>>> getAllReminders() async {
    try {
      final models = await localDataSource.getAllReminders();
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders() async {
    try {
      final models = await localDataSource.getUpcomingReminders();
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getCompletedReminders() async {
    try {
      final models = await localDataSource.getCompletedReminders();
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getRemindersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await localDataSource.getRemindersByDateRange(start, end);
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Reminder?>> getReminderById(Id id) async {
    try {
      final model = await localDataSource.getReminderById(id);
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getRemindersByLinkedItem(
    String linkedType,
    Id linkedId,
  ) async {
    try {
      final models =
          await localDataSource.getRemindersByLinkedItem(linkedType, linkedId);
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Id>> addReminder(Reminder reminder) async {
    try {
      final id =
          await localDataSource.addReminder(ReminderModel.fromEntity(reminder));
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateReminder(Reminder reminder) async {
    try {
      final success = await localDataSource
          .updateReminder(ReminderModel.fromEntity(reminder));
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReminder(Id id) async {
    try {
      final success = await localDataSource.deleteReminder(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> markReminderAsCompleted(Id id) async {
    try {
      final success = await localDataSource.markReminderAsCompleted(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
