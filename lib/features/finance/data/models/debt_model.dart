import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';

part 'debt_model.g.dart';

@collection
class DebtModel {
  Id id = Isar.autoIncrement;

  late String type; // 'i_owe' or 'owed_to_me'
  late double amount;
  late double paidAmount; // Total amount paid so far
  late String person; // Person/entity name
  @Index()
  late DateTime dueDate;
  DateTime? createdAt;
  String? note;
  bool isPaid = false;

  DebtModel();

  Debt toEntity() {
    return Debt(
      id: id,
      type: type,
      amount: amount,
      paidAmount: paidAmount,
      person: person,
      dueDate: dueDate,
      createdAt: createdAt,
      note: note,
      isPaid: isPaid,
    );
  }

  factory DebtModel.fromEntity(Debt entity) {
    final model = DebtModel()
      ..type = entity.type
      ..amount = entity.amount
      ..paidAmount = entity.paidAmount
      ..person = entity.person
      ..dueDate = entity.dueDate
      ..createdAt = entity.createdAt
      ..note = entity.note
      ..isPaid = entity.isPaid;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  DebtModel copyWith({
    Id? id,
    String? type,
    double? amount,
    double? paidAmount,
    String? person,
    DateTime? dueDate,
    DateTime? createdAt,
    String? note,
    bool? isPaid,
  }) {
    final model = DebtModel()
      ..type = type ?? this.type
      ..amount = amount ?? this.amount
      ..paidAmount = paidAmount ?? this.paidAmount
      ..person = person ?? this.person
      ..dueDate = dueDate ?? this.dueDate
      ..createdAt = createdAt ?? this.createdAt
      ..note = note ?? this.note
      ..isPaid = isPaid ?? this.isPaid;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
