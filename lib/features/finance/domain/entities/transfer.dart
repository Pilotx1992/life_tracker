import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Transfer extends Equatable {
  final Id? id;
  final double amount;
  final String currency;
  final Id fromAccountId; // Source account
  final Id toAccountId; // Destination account
  final DateTime date;
  final String? note;

  const Transfer({
    this.id,
    required this.amount,
    required this.currency,
    required this.fromAccountId,
    required this.toAccountId,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props =>
      [id, amount, currency, fromAccountId, toAccountId, date, note];

  Transfer copyWith({
    Id? id,
    double? amount,
    String? currency,
    Id? fromAccountId,
    Id? toAccountId,
    DateTime? date,
    String? note,
  }) {
    return Transfer(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
