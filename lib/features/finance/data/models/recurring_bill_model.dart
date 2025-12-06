import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';

part 'recurring_bill_model.g.dart';

@collection
class RecurringBillModel {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount;
  late String currency;
  @Index()
  late int categoryId; // Reference to CategoryModel (for expense creation)
  @Index()
  late int accountId; // Reference to AccountModel (for expense creation)
  late String frequency; // Monthly, Weekly, Yearly
  late int
      dayOfSchedule; // Day of month (1-31) for Monthly/Yearly, Day of week (1-7, Mon-Sun) for Weekly
  @Index()
  late DateTime nextDueDate;
  int reminderDaysBefore = 3; // Days before due date to send reminder
  String? note;
  bool isActive = true; // Whether this bill is currently active
  late DateTime createdAt;

  RecurringBillModel();

  RecurringBill toEntity() {
    return RecurringBill(
      id: id,
      name: name,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      accountId: accountId,
      frequency: frequency,
      dayOfSchedule: dayOfSchedule,
      nextDueDate: nextDueDate,
      reminderDaysBefore: reminderDaysBefore,
      note: note,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory RecurringBillModel.fromEntity(RecurringBill entity) {
    final model = RecurringBillModel()
      ..name = entity.name
      ..amount = entity.amount
      ..currency = entity.currency
      ..categoryId = entity.categoryId
      ..accountId = entity.accountId
      ..frequency = entity.frequency
      ..dayOfSchedule = entity.dayOfSchedule
      ..nextDueDate = entity.nextDueDate
      ..reminderDaysBefore = entity.reminderDaysBefore
      ..note = entity.note
      ..isActive = entity.isActive
      ..createdAt = entity.createdAt;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  RecurringBillModel copyWith({
    Id? id,
    String? name,
    double? amount,
    String? currency,
    int? categoryId,
    int? accountId,
    String? frequency,
    int? dayOfSchedule,
    DateTime? nextDueDate,
    int? reminderDaysBefore,
    String? note,
    bool? isActive,
    DateTime? createdAt,
  }) {
    final model = RecurringBillModel()
      ..name = name ?? this.name
      ..amount = amount ?? this.amount
      ..currency = currency ?? this.currency
      ..categoryId = categoryId ?? this.categoryId
      ..accountId = accountId ?? this.accountId
      ..frequency = frequency ?? this.frequency
      ..dayOfSchedule = dayOfSchedule ?? this.dayOfSchedule
      ..nextDueDate = nextDueDate ?? this.nextDueDate
      ..reminderDaysBefore = reminderDaysBefore ?? this.reminderDaysBefore
      ..note = note ?? this.note
      ..isActive = isActive ?? this.isActive
      ..createdAt = createdAt ?? this.createdAt;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
