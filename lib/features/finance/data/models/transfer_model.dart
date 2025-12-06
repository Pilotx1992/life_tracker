import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';

part 'transfer_model.g.dart';

@collection
class TransferModel {
  Id id = Isar.autoIncrement;

  late double amount;
  late String currency;
  @Index()
  late int fromAccountId; // Source account
  @Index()
  late int toAccountId; // Destination account
  @Index()
  late DateTime date;
  String? note;

  TransferModel();

  Transfer toEntity() {
    return Transfer(
      id: id,
      amount: amount,
      currency: currency,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      date: date,
      note: note,
    );
  }

  factory TransferModel.fromEntity(Transfer entity) {
    final model = TransferModel()
      ..amount = entity.amount
      ..currency = entity.currency
      ..fromAccountId = entity.fromAccountId
      ..toAccountId = entity.toAccountId
      ..date = entity.date
      ..note = entity.note;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  TransferModel copyWith({
    Id? id,
    double? amount,
    String? currency,
    int? fromAccountId,
    int? toAccountId,
    DateTime? date,
    String? note,
  }) {
    final model = TransferModel()
      ..amount = amount ?? this.amount
      ..currency = currency ?? this.currency
      ..fromAccountId = fromAccountId ?? this.fromAccountId
      ..toAccountId = toAccountId ?? this.toAccountId
      ..date = date ?? this.date
      ..note = note ?? this.note;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
