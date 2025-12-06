import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/domain/repositories/reminder_repository.dart';

class GetReminders implements UseCase<List<Reminder>, NoParams> {
  final ReminderRepository repository;

  GetReminders(this.repository);

  @override
  Future<Either<Failure, List<Reminder>>> call(NoParams params) async {
    return await repository.getAllReminders();
  }
}
