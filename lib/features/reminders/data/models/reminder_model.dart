import 'package:isar/isar.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';

part 'reminder_model.g.dart';

@collection
class ReminderModel {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  late DateTime dateTime;
  bool isCompleted = false;
  late String priority; // 'Low', 'Medium', 'High'
  bool isRecurring = false;
  String? recurringPattern; // 'Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom'
  int? recurringInterval; // For custom patterns (e.g., every 3 days)
  DateTime? recurringEndDate; // Optional end date for recurring reminders
  DateTime? nextOccurrence; // Next occurrence for recurring reminders

  // Linked item (optional)
  String? linkedType; // 'medication', 'bill', 'note', etc.
  int? linkedId; // ID of the linked item

  late DateTime createdAt;
  late DateTime updatedAt;

  ReminderModel();

  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      dateTime: dateTime,
      isCompleted: isCompleted,
      priority: priority,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      recurringInterval: recurringInterval,
      recurringEndDate: recurringEndDate,
      nextOccurrence: nextOccurrence,
      linkedType: linkedType,
      linkedId: linkedId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ReminderModel.fromEntity(Reminder entity) {
    final model = ReminderModel()
      ..title = entity.title
      ..description = entity.description
      ..dateTime = entity.dateTime
      ..isCompleted = entity.isCompleted
      ..priority = entity.priority
      ..isRecurring = entity.isRecurring
      ..recurringPattern = entity.recurringPattern
      ..recurringInterval = entity.recurringInterval
      ..recurringEndDate = entity.recurringEndDate
      ..nextOccurrence = entity.nextOccurrence
      ..linkedType = entity.linkedType
      ..linkedId = entity.linkedId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  ReminderModel copyWith({
    Id? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    String? priority,
    bool? isRecurring,
    String? recurringPattern,
    int? recurringInterval,
    DateTime? recurringEndDate,
    DateTime? nextOccurrence,
    String? linkedType,
    int? linkedId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final model = ReminderModel()
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..dateTime = dateTime ?? this.dateTime
      ..isCompleted = isCompleted ?? this.isCompleted
      ..priority = priority ?? this.priority
      ..isRecurring = isRecurring ?? this.isRecurring
      ..recurringPattern = recurringPattern ?? this.recurringPattern
      ..recurringInterval = recurringInterval ?? this.recurringInterval
      ..recurringEndDate = recurringEndDate ?? this.recurringEndDate
      ..nextOccurrence = nextOccurrence ?? this.nextOccurrence
      ..linkedType = linkedType ?? this.linkedType
      ..linkedId = linkedId ?? this.linkedId
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
