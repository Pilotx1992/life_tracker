import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

/// Bill type enumeration
enum BillType {
  recurring, // Monthly/yearly bills that repeat indefinitely
  installment, // Fixed number of payments that end when fully paid
}

class RecurringBill extends Equatable {
  final Id? id;
  final String name;
  final double amount;
  final String currency;
  final Id categoryId; // Reference to Category (for expense creation)
  final Id accountId; // Reference to Account (for expense creation)
  final String frequency; // Monthly, Weekly, Yearly
  final int
      dayOfSchedule; // Day of month (1-31) for Monthly/Yearly, Day of week (1-7, Mon-Sun) for Weekly
  final DateTime nextDueDate;
  final int reminderDaysBefore; // Days before due date to send reminder
  final String? note;
  final bool isActive; // Whether this bill is currently active
  final DateTime createdAt;

  // ✨ Installment-specific fields
  final BillType type; // 'recurring' or 'installment'
  final double totalAmount; // Total amount for installments (0 for recurring)
  final int totalInstallments; // Total number of installments (0 for recurring)
  final int paidInstallments; // Number of paid installments
  final double paidAmount; // Total amount paid so far

  const RecurringBill({
    this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.accountId,
    required this.frequency,
    required this.dayOfSchedule,
    required this.nextDueDate,
    this.reminderDaysBefore = 3,
    this.note,
    this.isActive = true,
    required this.createdAt,
    this.type = BillType.recurring,
    this.totalAmount = 0,
    this.totalInstallments = 0,
    this.paidInstallments = 0,
    this.paidAmount = 0,
  });

  // ✨ Computed getters for installments
  /// Remaining amount to be paid
  double get remainingAmount =>
      type == BillType.installment ? totalAmount - paidAmount : 0;

  /// Progress percentage (0-100)
  double get progressPercentage =>
      type == BillType.installment && totalAmount > 0
          ? (paidAmount / totalAmount) * 100
          : 0;

  /// Whether the installment is fully paid
  bool get isFullyPaid => type == BillType.installment && remainingAmount <= 0;

  /// Number of remaining installments
  int get remainingInstallments =>
      type == BillType.installment ? totalInstallments - paidInstallments : 0;

  /// Whether this is an installment type
  bool get isInstallment => type == BillType.installment;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        currency,
        categoryId,
        accountId,
        frequency,
        dayOfSchedule,
        nextDueDate,
        reminderDaysBefore,
        note,
        isActive,
        createdAt,
        type,
        totalAmount,
        totalInstallments,
        paidInstallments,
        paidAmount,
      ];

  RecurringBill copyWith({
    Id? id,
    String? name,
    double? amount,
    String? currency,
    Id? categoryId,
    Id? accountId,
    String? frequency,
    int? dayOfSchedule,
    DateTime? nextDueDate,
    int? reminderDaysBefore,
    String? note,
    bool? isActive,
    DateTime? createdAt,
    BillType? type,
    double? totalAmount,
    int? totalInstallments,
    int? paidInstallments,
    double? paidAmount,
  }) {
    return RecurringBill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      frequency: frequency ?? this.frequency,
      dayOfSchedule: dayOfSchedule ?? this.dayOfSchedule,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
