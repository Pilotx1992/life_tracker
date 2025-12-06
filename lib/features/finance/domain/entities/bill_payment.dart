import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class BillPayment extends Equatable {
  final Id? id;
  final Id billId; // Reference to RecurringBill
  final DateTime paidDate;
  final String? note;
  final Id? expenseId; // Reference to Expense (if expense was auto-created)

  const BillPayment({
    this.id,
    required this.billId,
    required this.paidDate,
    this.note,
    this.expenseId,
  });

  @override
  List<Object?> get props => [id, billId, paidDate, note, expenseId];

  BillPayment copyWith({
    Id? id,
    Id? billId,
    DateTime? paidDate,
    String? note,
    Id? expenseId,
  }) {
    return BillPayment(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      paidDate: paidDate ?? this.paidDate,
      note: note ?? this.note,
      expenseId: expenseId ?? this.expenseId,
    );
  }
}
