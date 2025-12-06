import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class CommitmentContribution extends Equatable {
  final Id? id;
  final Id commitmentId; // Reference to FinancialCommitment
  final double amount;
  final DateTime date;
  final String? note;

  const CommitmentContribution({
    this.id,
    required this.commitmentId,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, commitmentId, amount, date, note];

  CommitmentContribution copyWith({
    Id? id,
    Id? commitmentId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return CommitmentContribution(
      id: id ?? this.id,
      commitmentId: commitmentId ?? this.commitmentId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
