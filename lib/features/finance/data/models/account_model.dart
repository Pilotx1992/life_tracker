import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';

part 'account_model.g.dart';

@collection
class AccountModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String currency;
  late double balance;
  late String type; // Bank, Cash, Card, E-Wallet
  String? bankName; // Optional: for bank accounts
  String? cardLastDigits; // Optional: last 4 digits for cards
  String? notes; // Optional: additional notes
  double? creditLimit; // Optional: credit limit for Credit Card accounts

  AccountModel();

  Account toEntity() {
    return Account(
      id: id,
      name: name,
      currency: currency,
      balance: balance,
      type: type,
      bankName: bankName,
      cardLastDigits: cardLastDigits,
      notes: notes,
      creditLimit: creditLimit,
    );
  }

  factory AccountModel.fromEntity(Account entity) {
    final model = AccountModel()
      ..name = entity.name
      ..currency = entity.currency
      ..balance = entity.balance
      ..type = entity.type
      ..bankName = entity.bankName
      ..cardLastDigits = entity.cardLastDigits
      ..notes = entity.notes
      ..creditLimit = entity.creditLimit;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  AccountModel copyWith({
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
    final model = AccountModel()
      ..name = name ?? this.name
      ..currency = currency ?? this.currency
      ..balance = balance ?? this.balance
      ..type = type ?? this.type
      ..bankName = bankName ?? this.bankName
      ..cardLastDigits = cardLastDigits ?? this.cardLastDigits
      ..notes = notes ?? this.notes
      ..creditLimit = creditLimit ?? this.creditLimit;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
