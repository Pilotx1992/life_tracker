import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';

part 'commitment_contribution_model.g.dart';

@collection
class CommitmentContributionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int commitmentId; // Reference to FinancialCommitmentModel
  late double amount;
  @Index()
  late DateTime date;
  String? note;

  CommitmentContributionModel();

  CommitmentContribution toEntity() {
    return CommitmentContribution(
      id: id,
      commitmentId: commitmentId,
      amount: amount,
      date: date,
      note: note,
    );
  }

  factory CommitmentContributionModel.fromEntity(
    CommitmentContribution entity,
  ) {
    final model = CommitmentContributionModel()
      ..commitmentId = entity.commitmentId
      ..amount = entity.amount
      ..date = entity.date
      ..note = entity.note;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  CommitmentContributionModel copyWith({
    Id? id,
    int? commitmentId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    final model = CommitmentContributionModel()
      ..commitmentId = commitmentId ?? this.commitmentId
      ..amount = amount ?? this.amount
      ..date = date ?? this.date
      ..note = note ?? this.note;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
