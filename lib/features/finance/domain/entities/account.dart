import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Account extends Equatable {
  final Id? id;
  final String name;
  final String currency;
  final double balance;
  final String type; // Bank, Cash, Card, E-Wallet
  final String? bankName; // Optional: for bank accounts
  final String? cardLastDigits; // Optional: last 4 digits for cards
  final String? notes; // Optional: additional notes
  final double? creditLimit; // Optional: credit limit for Credit Card accounts

  const Account({
    this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.type,
    this.bankName,
    this.cardLastDigits,
    this.notes,
    this.creditLimit,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        currency,
        balance,
        type,
        bankName,
        cardLastDigits,
        notes,
        creditLimit,
      ];

  Account copyWith({
    Id? id,
    String? name,
    String? currency,
    double? balance,
    String? type,
    String? bankName,
    String? cardLastDigits,
    String? notes,
    double? creditLimit,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      bankName: bankName ?? this.bankName,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
      notes: notes ?? this.notes,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }
}
