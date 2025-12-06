import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';

part 'financial_commitment_model.g.dart';

@collection
class FinancialCommitmentModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String description;
  late double targetAmount;
  late double currentAmount; // Sum of all contributions
  late String currency;
  @Index()
  late DateTime deadline;
  @Index()
  late int
      accountId; // Reference to AccountModel (where contributions come from)
  String? note;
  bool isCompleted = false;
  late DateTime createdAt;
  late DateTime updatedAt;

  FinancialCommitmentModel();

  FinancialCommitment toEntity() {
    return FinancialCommitment(
      id: id,
      name: name,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      currency: currency,
      deadline: deadline,
      accountId: accountId,
      note: note,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FinancialCommitmentModel.fromEntity(FinancialCommitment entity) {
    final model = FinancialCommitmentModel()
      ..name = entity.name
      ..description = entity.description
      ..targetAmount = entity.targetAmount
      ..currentAmount = entity.currentAmount
      ..currency = entity.currency
      ..deadline = entity.deadline
      ..accountId = entity.accountId
      ..note = entity.note
      ..isCompleted = entity.isCompleted
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  FinancialCommitmentModel copyWith({
    Id? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? deadline,
    int? accountId,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final model = FinancialCommitmentModel()
      ..name = name ?? this.name
      ..description = description ?? this.description
      ..targetAmount = targetAmount ?? this.targetAmount
      ..currentAmount = currentAmount ?? this.currentAmount
      ..currency = currency ?? this.currency
      ..deadline = deadline ?? this.deadline
      ..accountId = accountId ?? this.accountId
      ..note = note ?? this.note
      ..isCompleted = isCompleted ?? this.isCompleted
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
