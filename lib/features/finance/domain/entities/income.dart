import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Income extends Equatable {
  final Id? id;
  final double amount;
  final String currency;
  final String source; // Salary, Freelance, Investment, Gift, Other
  final Id accountId; // Reference to Account
  final DateTime date;
  final String? note;
  final bool isRecurring; // Whether this is a recurring income
  final String? recurringFrequency; // Monthly, Weekly, Yearly (if recurring)

  const Income({
    this.id,
    required this.amount,
    required this.currency,
    required this.source,
    required this.accountId,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringFrequency,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        currency,
        source,
        accountId,
        date,
        note,
        isRecurring,
        recurringFrequency,
      ];

  Income copyWith({
    Id? id,
    double? amount,
    String? currency,
    String? source,
    Id? accountId,
    DateTime? date,
    String? note,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }
}
