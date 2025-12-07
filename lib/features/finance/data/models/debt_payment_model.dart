import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';

part 'debt_payment_model.g.dart';

@collection
class DebtPaymentModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int debtId; // Reference to DebtModel
  late double amount;
  @Index()
  late DateTime paymentDate;
  String? note;

  DebtPaymentModel();

  DebtPayment toEntity() {
    return DebtPayment(
      id: id,
      debtId: debtId,
      amount: amount,
      paymentDate: paymentDate,
      note: note,
    );
  }

  factory DebtPaymentModel.fromEntity(DebtPayment entity) {
    final model = DebtPaymentModel()
      ..debtId = entity.debtId
      ..amount = entity.amount
      ..paymentDate = entity.paymentDate
      ..note = entity.note;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  DebtPaymentModel copyWith({
    Id? id,
    int? debtId,
    double? amount,
    DateTime? paymentDate,
    String? note,
  }) {
    final model = DebtPaymentModel()
      ..debtId = debtId ?? this.debtId
      ..amount = amount ?? this.amount
      ..paymentDate = paymentDate ?? this.paymentDate
      ..note = note ?? this.note;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
