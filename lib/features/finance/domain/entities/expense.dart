import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Expense extends Equatable {
  final Id? id;
  final double amount;
  final String currency;
  final Id categoryId; // Reference to Category
  final Id accountId; // Reference to Account
  final DateTime date;
  final String? note;
  final String? receiptPath; // Path to receipt image file

  const Expense({
    this.id,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.note,
    this.receiptPath,
  });

  @override
  List<Object?> get props =>
      [id, amount, currency, categoryId, accountId, date, note, receiptPath];

  Expense copyWith({
    Id? id,
    double? amount,
    String? currency,
    Id? categoryId,
    Id? accountId,
    DateTime? date,
    String? note,
    String? receiptPath,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }
}
