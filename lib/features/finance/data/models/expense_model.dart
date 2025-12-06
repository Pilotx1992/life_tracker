import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';

part 'expense_model.g.dart';

@collection
class ExpenseModel {
  Id id = Isar.autoIncrement;

  late double amount;
  late String currency;
  @Index()
  late int categoryId; // Reference to CategoryModel
  @Index()
  late int accountId; // Reference to AccountModel
  @Index()
  late DateTime date;
  String? note;
  String? receiptPath; // Path to receipt image file

  ExpenseModel();

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      accountId: accountId,
      date: date,
      note: note,
      receiptPath: receiptPath,
    );
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    final model = ExpenseModel()
      ..amount = entity.amount
      ..currency = entity.currency
      ..categoryId = entity.categoryId
      ..accountId = entity.accountId
      ..date = entity.date
      ..note = entity.note
      ..receiptPath = entity.receiptPath;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  ExpenseModel copyWith({
    Id? id,
    double? amount,
    String? currency,
    int? categoryId,
    int? accountId,
    DateTime? date,
    String? note,
    String? receiptPath,
  }) {
    final model = ExpenseModel()
      ..amount = amount ?? this.amount
      ..currency = currency ?? this.currency
      ..categoryId = categoryId ?? this.categoryId
      ..accountId = accountId ?? this.accountId
      ..date = date ?? this.date
      ..note = note ?? this.note
      ..receiptPath = receiptPath ?? this.receiptPath;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
