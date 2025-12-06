import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/domain/repositories/reminder_repository.dart';

class UpdateReminder implements UseCase<bool, Reminder> {
  final ReminderRepository repository;

  UpdateReminder(this.repository);

  @override
  Future<Either<Failure, bool>> call(Reminder params) async {
    return await repository.updateReminder(params);
  }
}
