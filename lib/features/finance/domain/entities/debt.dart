import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Debt extends Equatable {
  final Id? id;
  final String type; // 'i_owe' or 'owed_to_me'
  final double amount;
  final double paidAmount; // Total amount paid so far
  final String person; // Person/entity name
  final DateTime dueDate;
  final DateTime? createdAt;
  final String? note;
  final bool isPaid;

  const Debt({
    this.id,
    required this.type,
    required this.amount,
    this.paidAmount = 0.0,
    required this.person,
    required this.dueDate,
    this.createdAt,
    this.note,
    this.isPaid = false,
  });

  double get remainingAmount => amount - paidAmount;
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        paidAmount,
        person,
        dueDate,
        createdAt,
        note,
        isPaid,
      ];

  Debt copyWith({
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
    return Debt(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      person: person ?? this.person,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
