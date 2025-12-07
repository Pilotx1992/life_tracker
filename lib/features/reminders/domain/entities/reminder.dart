import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Reminder extends Equatable {
  final Id? id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final bool isCompleted;
  final String priority; // 'Low', 'Medium', 'High'
  final bool isRecurring;
  final String?
      recurringPattern; // 'Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom'
  final int? recurringInterval; // For custom patterns (e.g., every 3 days)
  final DateTime? recurringEndDate; // Optional end date for recurring reminders
  final DateTime? nextOccurrence; // Next occurrence for recurring reminders

  // Linked item (optional)
  final String? linkedType; // 'medication', 'bill', 'note', etc.
  final Id? linkedId; // ID of the linked item

  // Alarm properties
  final bool hasAlarm; // Whether reminder has alarm enabled
  final String? alarmSound; // Path to alarm sound file
  final bool vibrate; // Whether to vibrate
  final int snoozeDuration; // Snooze duration in minutes (default: 5)
  final int repeatCount; // How many times to repeat alarm sound (-1 for infinite)

  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringInterval,
    this.recurringEndDate,
    this.nextOccurrence,
    this.linkedType,
    this.linkedId,
    this.hasAlarm = false,
    this.alarmSound,
    this.vibrate = true,
    this.snoozeDuration = 5,
    this.repeatCount = -1, // -1 means infinite
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if reminder is overdue
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dateTime);

  /// Check if reminder is due today
  bool get isDueToday {
    final now = DateTime.now();
    return !isCompleted &&
        dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if reminder is due tomorrow
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return !isCompleted &&
        dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  /// Check if reminder is due this week
  bool get isDueThisWeek {
    if (isCompleted) return false;
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return dateTime.isAfter(now) && dateTime.isBefore(weekFromNow);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dateTime,
        isCompleted,
        priority,
        isRecurring,
        recurringPattern,
        recurringInterval,
        recurringEndDate,
        nextOccurrence,
        linkedType,
        linkedId,
        hasAlarm,
        alarmSound,
        vibrate,
        snoozeDuration,
        repeatCount,
        createdAt,
        updatedAt,
      ];

  Reminder copyWith({
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
    Id? linkedId,
    bool? hasAlarm,
    String? alarmSound,
    bool? vibrate,
    int? snoozeDuration,
    int? repeatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      linkedType: linkedType ?? this.linkedType,
      linkedId: linkedId ?? this.linkedId,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      alarmSound: alarmSound ?? this.alarmSound,
      vibrate: vibrate ?? this.vibrate,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      repeatCount: repeatCount ?? this.repeatCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
