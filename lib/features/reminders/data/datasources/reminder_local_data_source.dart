import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/reminders/data/models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getAllReminders();
  Future<List<ReminderModel>> getUpcomingReminders();
  Future<List<ReminderModel>> getCompletedReminders();
  Future<List<ReminderModel>> getRemindersByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<ReminderModel?> getReminderById(Id id);
  Future<List<ReminderModel>> getRemindersByLinkedItem(
    String linkedType,
    Id linkedId,
  );
  Future<Id> addReminder(ReminderModel reminder);
  Future<bool> updateReminder(ReminderModel reminder);
  Future<bool> deleteReminder(Id id);
  Future<bool> markReminderAsCompleted(Id id);
  Future<int> autoCompleteExpiredReminders();
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final DatabaseService _databaseService;

  ReminderLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final isar = await _databaseService.database;
      return await isar.reminderModels.where().sortByDateTime().findAll();
    } catch (e) {
      throw CacheException('Failed to get all reminders: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders() async {
    try {
      final isar = await _databaseService.database;
      final now = DateTime.now();
      // Show reminders that are not completed and dateTime is >= now
      // Use subtract 1 second to include reminders at the current moment
      return await isar.reminderModels
          .filter()
          .isCompletedEqualTo(false)
          .dateTimeGreaterThan(now.subtract(const Duration(seconds: 1)))
          .sortByDateTime()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get upcoming reminders: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getCompletedReminders() async {
    try {
      final isar = await _databaseService.database;
      // Use distinctBy to ensure unique results
      final reminders = await isar.reminderModels
          .filter()
          .isCompletedEqualTo(true)
          .sortByDateTimeDesc()
          .findAll();
      // Remove duplicates by ID (safety check)
      final seenIds = <Id>{};
      return reminders.where((reminder) {
        if (seenIds.contains(reminder.id)) return false;
        seenIds.add(reminder.id);
        return true;
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get completed reminders: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getRemindersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final isar = await _databaseService.database;
      return await isar.reminderModels
          .filter()
          .dateTimeGreaterThan(start.subtract(const Duration(seconds: 1)))
          .dateTimeLessThan(end.add(const Duration(seconds: 1)))
          .sortByDateTime()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get reminders by date range: $e');
    }
  }

  @override
  Future<ReminderModel?> getReminderById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.reminderModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get reminder by ID: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getRemindersByLinkedItem(
    String linkedType,
    Id linkedId,
  ) async {
    try {
      final isar = await _databaseService.database;
      return await isar.reminderModels
          .filter()
          .linkedTypeEqualTo(linkedType)
          .linkedIdEqualTo(linkedId)
          .sortByDateTime()
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get reminders by linked item: $e');
    }
  }

  @override
  Future<Id> addReminder(ReminderModel reminder) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.reminderModels.put(reminder);
      });
    } catch (e) {
      throw CacheException('Failed to add reminder: $e');
    }
  }

  @override
  Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.reminderModels.put(reminder) > 0;
      });
    } catch (e) {
      throw CacheException('Failed to update reminder: $e');
    }
  }

  @override
  Future<bool> deleteReminder(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.reminderModels.delete(id);
      });
    } catch (e) {
      throw CacheException('Failed to delete reminder: $e');
    }
  }

  @override
  Future<bool> markReminderAsCompleted(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        final reminder = await isar.reminderModels.get(id);
        if (reminder == null) return false;

        final updated = reminder.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
        return await isar.reminderModels.put(updated) > 0;
      });
    } catch (e) {
      throw CacheException('Failed to mark reminder as completed: $e');
    }
  }

  @override
  Future<int> autoCompleteExpiredReminders() async {
    try {
      final isar = await _databaseService.database;
      final now = DateTime.now();

      // Find all non-completed reminders with dateTime in the past
      final expiredReminders = await isar.reminderModels
          .filter()
          .isCompletedEqualTo(false)
          .dateTimeLessThan(now)
          .findAll();

      if (expiredReminders.isEmpty) return 0;

      // Mark them as completed
      return await isar.writeTxn(() async {
        int count = 0;
        for (final reminder in expiredReminders) {
          final updated = reminder.copyWith(
            isCompleted: true,
            updatedAt: DateTime.now(),
          );
          if (await isar.reminderModels.put(updated) > 0) {
            count++;
          }
        }
        return count;
      });
    } catch (e) {
      throw CacheException('Failed to auto-complete expired reminders: $e');
    }
  }
}
