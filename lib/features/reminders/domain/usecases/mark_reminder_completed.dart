import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/reminders/domain/repositories/reminder_repository.dart';

class MarkReminderCompleted implements UseCase<bool, Id> {
  final ReminderRepository repository;

  MarkReminderCompleted(this.repository);

  @override
  Future<Either<Failure, bool>> call(Id params) async {
    return await repository.markReminderAsCompleted(params);
  }
}
