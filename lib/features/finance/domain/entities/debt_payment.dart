import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class DebtPayment extends Equatable {
  final Id? id;
  final Id debtId; // Reference to Debt
  final double amount;
  final DateTime paymentDate;
  final String? note;

  const DebtPayment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.note,
  });

  @override
  List<Object?> get props => [id, debtId, amount, paymentDate, note];

  DebtPayment copyWith({
    Id? id,
    Id? debtId,
    double? amount,
    DateTime? paymentDate,
    String? note,
  }) {
    return DebtPayment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      note: note ?? this.note,
    );
  }
}
