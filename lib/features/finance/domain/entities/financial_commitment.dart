import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class FinancialCommitment extends Equatable {
  final Id? id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount; // Sum of all contributions
  final String currency;
  final DateTime deadline;
  final Id accountId; // Reference to Account (where contributions come from)
  final String? note;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialCommitment({
    this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.currency,
    required this.deadline,
    required this.accountId,
    this.note,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progress percentage (0.0 to 1.0)
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Remaining amount to reach target
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, targetAmount);

  /// Days remaining until deadline
  int get daysRemaining {
    final now = DateTime.now();
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = deadlineDate.difference(today).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Suggested monthly savings amount
  double get suggestedMonthlySavings {
    final days = daysRemaining;
    if (days <= 0 || remainingAmount <= 0) return 0.0;
    // Approximate months remaining (30 days per month)
    final monthsRemaining = days / 30.0;
    if (monthsRemaining <= 0) return remainingAmount;
    return remainingAmount / monthsRemaining;
  }

  /// Whether the commitment is overdue (past deadline and not completed)
  bool get isOverdue =>
      !isCompleted && daysRemaining == 0 && currentAmount < targetAmount;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        targetAmount,
        currentAmount,
        currency,
        deadline,
        accountId,
        note,
        isCompleted,
        createdAt,
        updatedAt,
      ];

  FinancialCommitment copyWith({
    Id? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? deadline,
    Id? accountId,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialCommitment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
      accountId: accountId ?? this.accountId,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
