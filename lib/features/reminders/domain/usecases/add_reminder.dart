import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/domain/repositories/reminder_repository.dart';

class AddReminder implements UseCase<Id, Reminder> {
  final ReminderRepository repository;

  AddReminder(this.repository);

  @override
  Future<Either<Failure, Id>> call(Reminder params) async {
    return await repository.addReminder(params);
  }
}
