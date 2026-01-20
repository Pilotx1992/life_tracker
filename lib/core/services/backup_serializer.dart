import 'package:life_tracker/features/finance/data/models/account_model.dart';
import 'package:life_tracker/features/finance/data/models/bill_payment_model.dart';
import 'package:life_tracker/features/finance/data/models/category_model.dart';
import 'package:life_tracker/features/finance/data/models/commitment_contribution_model.dart';
import 'package:life_tracker/features/finance/data/models/debt_model.dart';
import 'package:life_tracker/features/finance/data/models/debt_payment_model.dart';
import 'package:life_tracker/features/finance/data/models/expense_model.dart';
import 'package:life_tracker/features/finance/data/models/financial_commitment_model.dart';
import 'package:life_tracker/features/finance/data/models/income_model.dart';
import 'package:life_tracker/features/finance/data/models/recurring_bill_model.dart';
import 'package:life_tracker/features/health/data/models/medication_intake_model.dart';
import 'package:life_tracker/features/health/data/models/medication_model.dart';
import 'package:life_tracker/features/health/data/models/user_profile_model.dart';
import 'package:life_tracker/features/health/data/models/weight_model.dart';
import 'package:life_tracker/features/notes/data/models/note_model.dart';
import 'package:life_tracker/features/notes/data/models/checklist_item_model.dart';
import 'package:life_tracker/features/reminders/data/models/reminder_model.dart';

/// Helper class to serialize Isar models to JSON
class BackupSerializer {
  /// Serialize UserProfileModel to JSON
  static Map<String, dynamic> userProfileToJson(UserProfileModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'height': model.height,
      'age': model.age,
      'gender': model.gender,
      'photo': model.photo,
    };
  }

  /// Serialize WeightModel to JSON
  static Map<String, dynamic> weightToJson(WeightModel model) {
    return {
      'id': model.id,
      'weight': model.weight,
      'date': model.date.toIso8601String(),
      'note': model.note,
    };
  }

  /// Serialize MedicationModel to JSON
  static Map<String, dynamic> medicationToJson(MedicationModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'dosage': model.dosage,
      'times': model.times.map((t) => t.toIso8601String()).toList(),
      'instructions': model.instructions,
      'startDate': model.startDate.toIso8601String(),
      'endDate': model.endDate?.toIso8601String(),
    };
  }

  /// Serialize MedicationIntakeModel to JSON
  static Map<String, dynamic> medicationIntakeToJson(
    MedicationIntakeModel model,
  ) {
    return {
      'id': model.id,
      'medicationId': model.medicationId,
      'scheduledTime': model.scheduledTime.toIso8601String(),
      'actualTakenTime': model.actualTakenTime?.toIso8601String(),
      'isTaken': model.isTaken,
    };
  }

  /// Serialize AccountModel to JSON
  static Map<String, dynamic> accountToJson(AccountModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'type': model.type,
      'balance': model.balance,
      'currency': model.currency,
      'bankName': model.bankName,
      'cardLastDigits': model.cardLastDigits,
      'notes': model.notes,
    };
  }

  /// Serialize CategoryModel to JSON
  static Map<String, dynamic> categoryToJson(CategoryModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'icon': model.icon,
      'color': model.color,
      'isDefault': model.isDefault,
    };
  }

  /// Serialize ExpenseModel to JSON
  static Map<String, dynamic> expenseToJson(ExpenseModel model) {
    return {
      'id': model.id,
      'accountId': model.accountId,
      'categoryId': model.categoryId,
      'amount': model.amount,
      'currency': model.currency,
      'date': model.date.toIso8601String(),
      'note': model.note,
      'receiptPath': model.receiptPath,
    };
  }

  /// Serialize IncomeModel to JSON
  static Map<String, dynamic> incomeToJson(IncomeModel model) {
    return {
      'id': model.id,
      'accountId': model.accountId,
      'amount': model.amount,
      'currency': model.currency,
      'source': model.source,
      'date': model.date.toIso8601String(),
      'note': model.note,
      'isRecurring': model.isRecurring,
      'recurringFrequency': model.recurringFrequency,
    };
  }

  /// Serialize DebtModel to JSON
  static Map<String, dynamic> debtToJson(DebtModel model) {
    return {
      'id': model.id,
      'type': model.type,
      'amount': model.amount,
      'paidAmount': model.paidAmount,
      'person': model.person,
      'dueDate': model.dueDate.toIso8601String(),
      'createdAt': model.createdAt?.toIso8601String(),
      'note': model.note,
      'isPaid': model.isPaid,
    };
  }

  /// Serialize DebtPaymentModel to JSON
  static Map<String, dynamic> debtPaymentToJson(DebtPaymentModel model) {
    return {
      'id': model.id,
      'debtId': model.debtId,
      'amount': model.amount,
      'paymentDate': model.paymentDate.toIso8601String(),
      'note': model.note,
    };
  }

  /// Serialize RecurringBillModel to JSON
  static Map<String, dynamic> recurringBillToJson(RecurringBillModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'amount': model.amount,
      'currency': model.currency,
      'categoryId': model.categoryId,
      'accountId': model.accountId,
      'frequency': model.frequency,
      'dayOfSchedule': model.dayOfSchedule,
      'nextDueDate': model.nextDueDate.toIso8601String(),
      'reminderDaysBefore': model.reminderDaysBefore,
      'note': model.note,
      'isActive': model.isActive,
      'createdAt': model.createdAt.toIso8601String(),
    };
  }

  /// Serialize BillPaymentModel to JSON
  static Map<String, dynamic> billPaymentToJson(BillPaymentModel model) {
    return {
      'id': model.id,
      'billId': model.billId,
      'paidDate': model.paidDate.toIso8601String(),
      'note': model.note,
      'expenseId': model.expenseId,
    };
  }

  /// Serialize FinancialCommitmentModel to JSON
  static Map<String, dynamic> financialCommitmentToJson(
    FinancialCommitmentModel model,
  ) {
    return {
      'id': model.id,
      'name': model.name,
      'description': model.description,
      'targetAmount': model.targetAmount,
      'currentAmount': model.currentAmount,
      'currency': model.currency,
      'deadline': model.deadline.toIso8601String(),
      'accountId': model.accountId,
      'note': model.note,
      'isCompleted': model.isCompleted,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }

  /// Serialize CommitmentContributionModel to JSON
  static Map<String, dynamic> commitmentContributionToJson(
    CommitmentContributionModel model,
  ) {
    return {
      'id': model.id,
      'commitmentId': model.commitmentId,
      'amount': model.amount,
      'date': model.date.toIso8601String(),
      'note': model.note,
    };
  }

  /// Serialize NoteModel to JSON
  static Map<String, dynamic> noteToJson(NoteModel model) {
    return {
      'id': model.id,
      'title': model.title,
      'content': model.content,
      'color': model.color,
      'attachmentPaths': model.attachmentPaths,
      'voiceNotePath': model.voiceNotePath,
      'checklistItems': model.checklistItems
          .map((item) => checklistItemToJson(item))
          .toList(),
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }

  /// Serialize ChecklistItemModel to JSON
  static Map<String, dynamic> checklistItemToJson(ChecklistItemModel model) {
    return {
      'text': model.text,
      'isChecked': model.isChecked,
    };
  }

  /// Serialize ReminderModel to JSON
  static Map<String, dynamic> reminderToJson(ReminderModel model) {
    return {
      'id': model.id,
      'title': model.title,
      'description': model.description,
      'dateTime': model.dateTime.toIso8601String(),
      'isCompleted': model.isCompleted,
      'priority': model.priority,
      'isRecurring': model.isRecurring,
      'recurringPattern': model.recurringPattern,
      'recurringInterval': model.recurringInterval,
      'recurringEndDate': model.recurringEndDate?.toIso8601String(),
      'nextOccurrence': model.nextOccurrence?.toIso8601String(),
      'linkedType': model.linkedType,
      'linkedId': model.linkedId,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }
}
