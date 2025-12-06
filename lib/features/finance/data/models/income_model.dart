import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';

part 'income_model.g.dart';

@collection
class IncomeModel {
  Id id = Isar.autoIncrement;

  late double amount;
  late String currency;
  late String source; // Salary, Freelance, Investment, Gift, Other
  @Index()
  late int accountId; // Reference to AccountModel
  @Index()
  late DateTime date;
  String? note;
  bool isRecurring = false; // Whether this is a recurring income
  String? recurringFrequency; // Monthly, Weekly, Yearly (if recurring)

  IncomeModel();

  Income toEntity() {
    return Income(
      id: id,
      amount: amount,
      currency: currency,
      source: source,
      accountId: accountId,
      date: date,
      note: note,
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
    );
  }

  factory IncomeModel.fromEntity(Income entity) {
    final model = IncomeModel()
      ..amount = entity.amount
      ..currency = entity.currency
      ..source = entity.source
      ..accountId = entity.accountId
      ..date = entity.date
      ..note = entity.note
      ..isRecurring = entity.isRecurring
      ..recurringFrequency = entity.recurringFrequency;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  IncomeModel copyWith({
    Id? id,
    double? amount,
    String? currency,
    String? source,
    int? accountId,
    DateTime? date,
    String? note,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    final model = IncomeModel()
      ..amount = amount ?? this.amount
      ..currency = currency ?? this.currency
      ..source = source ?? this.source
      ..accountId = accountId ?? this.accountId
      ..date = date ?? this.date
      ..note = note ?? this.note
      ..isRecurring = isRecurring ?? this.isRecurring
      ..recurringFrequency = recurringFrequency ?? this.recurringFrequency;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
