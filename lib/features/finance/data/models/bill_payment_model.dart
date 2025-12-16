import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/bill_payment.dart';

part 'bill_payment_model.g.dart';

@collection
class BillPaymentModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int billId; // Reference to RecurringBillModel
  @Index()
  late DateTime paidDate;
  late double amount; // ✨ Payment amount
  String? note;
  @Index()
  int? expenseId; // Reference to ExpenseModel (if expense was auto-created)

  BillPaymentModel();

  BillPayment toEntity() {
    return BillPayment(
      id: id,
      billId: billId,
      paidDate: paidDate,
      amount: amount,
      note: note,
      expenseId: expenseId,
    );
  }

  factory BillPaymentModel.fromEntity(BillPayment entity) {
    final model = BillPaymentModel()
      ..billId = entity.billId
      ..paidDate = entity.paidDate
      ..amount = entity.amount
      ..note = entity.note
      ..expenseId = entity.expenseId;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  BillPaymentModel copyWith({
    Id? id,
    int? billId,
    DateTime? paidDate,
    double? amount,
    String? note,
    int? expenseId,
  }) {
    final model = BillPaymentModel()
      ..billId = billId ?? this.billId
      ..paidDate = paidDate ?? this.paidDate
      ..amount = amount ?? this.amount
      ..note = note ?? this.note
      ..expenseId = expenseId ?? this.expenseId;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
