import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/services/backup_service.dart';

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

/// Service for restoring data from backups
class RestoreService {
  RestoreService._(); // Private constructor for singleton

  static final RestoreService instance = RestoreService._();

  final BackupService _backupService = BackupService.instance;

  /// Restore data from backup file
  /// [filePath] - Path to backup file
  /// [password] - Password for encrypted backups (optional)
  /// [conflictStrategy] - 'replace' to replace all data, 'merge' to merge with existing
  Future<bool> restoreFromBackup({
    required String filePath,
    String? password,
    required String conflictStrategy, // 'replace' or 'merge'
  }) async {
    try {
      // Read backup file
      final backupData =
          await _backupService.readBackup(filePath, password: password);

      if (backupData['version'] == null) {
        throw Exception('Invalid backup file format');
      }

      final data = backupData['data'] as Map<String, dynamic>;
      final isar = await DatabaseService.instance.database;

      // Start transaction
      await isar.writeTxn(() async {
        // Handle conflict strategy
        if (conflictStrategy == 'replace') {
          // Clear all existing data
          await _clearAllData(isar);
        }
        // For 'merge', we keep existing data and add/update from backup

        // Restore Health data
        await _restoreUserProfiles(
          isar,
          data['userProfiles'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreWeights(
          isar,
          data['weights'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreMedications(
          isar,
          data['medications'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreMedicationIntakes(
          isar,
          data['medicationIntakes'] as List<dynamic>?,
          conflictStrategy,
        );

        // Restore Finance data
        await _restoreAccounts(
          isar,
          data['accounts'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreCategories(
          isar,
          data['categories'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreExpenses(
          isar,
          data['expenses'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreIncomes(
          isar,
          data['incomes'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreDebts(
          isar,
          data['debts'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreDebtPayments(
          isar,
          data['debtPayments'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreRecurringBills(
          isar,
          data['recurringBills'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreBillPayments(
          isar,
          data['billPayments'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreFinancialCommitments(
          isar,
          data['financialCommitments'] as List<dynamic>?,
          conflictStrategy,
        );
        await _restoreCommitmentContributions(
          isar,
          data['commitmentContributions'] as List<dynamic>?,
          conflictStrategy,
        );

        // Restore Notes data
        await _restoreNotes(
          isar,
          data['notes'] as List<dynamic>?,
          conflictStrategy,
        );

        // Restore Reminders data
        await _restoreReminders(
          isar,
          data['reminders'] as List<dynamic>?,
          conflictStrategy,
        );
      });

      if (kDebugMode) {
        debugPrint('Restore completed successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error restoring backup: $e');
      }
      rethrow;
    }
  }

  /// Clear all data from database
  Future<void> _clearAllData(Isar isar) async {
    await isar.userProfileModels.clear();
    await isar.weightModels.clear();
    await isar.medicationModels.clear();
    await isar.medicationIntakeModels.clear();
    await isar.accountModels.clear();
    await isar.categoryModels.clear();
    await isar.expenseModels.clear();
    await isar.incomeModels.clear();
    await isar.debtModels.clear();
    await isar.debtPaymentModels.clear();
    await isar.recurringBillModels.clear();
    await isar.billPaymentModels.clear();
    await isar.financialCommitmentModels.clear();
    await isar.commitmentContributionModels.clear();
    await isar.noteModels.clear();
    await isar.reminderModels.clear();
  }

  /// Restore user profiles
  Future<void> _restoreUserProfiles(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = UserProfileModel()
        ..id = item['id'] as int
        ..name = item['name'] as String?
        ..height = item['height'] as double?
        ..age = item['age'] as int?
        ..gender = item['gender'] as String?
        ..photo = item['photo'] as String?;
      await isar.userProfileModels.put(model);
    }
  }

  /// Restore weights
  Future<void> _restoreWeights(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = WeightModel(
        weight: (item['weight'] as num).toDouble(),
        date: DateTime.parse(item['date'] as String),
        note: item['note'] as String?,
      )..id = item['id'] as int;
      await isar.weightModels.put(model);
    }
  }

  /// Restore medications
  Future<void> _restoreMedications(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = MedicationModel(
        name: item['name'] as String,
        dosage: item['dosage'] as String,
        times: (item['times'] as List<dynamic>)
            .map((t) => DateTime.parse(t as String))
            .toList(),
        instructions: item['instructions'] as String?,
        startDate: DateTime.parse(item['startDate'] as String),
        endDate: item['endDate'] != null
            ? DateTime.parse(item['endDate'] as String)
            : null,
      )..id = item['id'] as int;
      await isar.medicationModels.put(model);
    }
  }

  /// Restore medication intakes
  Future<void> _restoreMedicationIntakes(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = MedicationIntakeModel(
        medicationId: item['medicationId'] as int,
        scheduledTime: DateTime.parse(item['scheduledTime'] as String),
        actualTakenTime: item['actualTakenTime'] != null
            ? DateTime.parse(item['actualTakenTime'] as String)
            : null,
        isTaken: item['isTaken'] as bool? ?? false,
      )..id = item['id'] as int;
      await isar.medicationIntakeModels.put(model);
    }
  }

  /// Restore accounts
  Future<void> _restoreAccounts(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = AccountModel()
        ..id = item['id'] as int
        ..name = item['name'] as String
        ..currency = item['currency'] as String
        ..balance = (item['balance'] as num).toDouble()
        ..type = item['type'] as String
        ..bankName = item['bankName'] as String?
        ..cardLastDigits = item['cardLastDigits'] as String?
        ..notes = item['notes'] as String?;
      await isar.accountModels.put(model);
    }
  }

  /// Restore categories
  Future<void> _restoreCategories(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = CategoryModel()
        ..id = item['id'] as int
        ..name = item['name'] as String
        ..icon = item['icon'] as String
        ..color = item['color'] as String
        ..isDefault = item['isDefault'] as bool? ?? false;
      await isar.categoryModels.put(model);
    }
  }

  /// Restore expenses
  Future<void> _restoreExpenses(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = ExpenseModel()
        ..id = item['id'] as int
        ..amount = (item['amount'] as num).toDouble()
        ..currency = item['currency'] as String
        ..categoryId = item['categoryId'] as int
        ..accountId = item['accountId'] as int
        ..date = DateTime.parse(item['date'] as String)
        ..note = item['note'] as String?
        ..receiptPath = item['receiptPath'] as String?;
      await isar.expenseModels.put(model);
    }
  }

  /// Restore incomes
  Future<void> _restoreIncomes(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = IncomeModel()
        ..id = item['id'] as int
        ..amount = (item['amount'] as num).toDouble()
        ..currency = item['currency'] as String
        ..source = item['source'] as String
        ..accountId = item['accountId'] as int
        ..date = DateTime.parse(item['date'] as String)
        ..note = item['note'] as String?
        ..isRecurring = item['isRecurring'] as bool? ?? false
        ..recurringFrequency = item['recurringFrequency'] as String?;
      await isar.incomeModels.put(model);
    }
  }

  /// Restore debts
  Future<void> _restoreDebts(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = DebtModel()
        ..id = item['id'] as int
        ..type = item['type'] as String
        ..amount = (item['amount'] as num).toDouble()
        ..paidAmount = (item['paidAmount'] as num).toDouble()
        ..person = item['person'] as String
        ..dueDate = DateTime.parse(item['dueDate'] as String)
        ..createdAt = item['createdAt'] != null
            ? DateTime.parse(item['createdAt'] as String)
            : null
        ..note = item['note'] as String?
        ..isPaid = item['isPaid'] as bool? ?? false;
      await isar.debtModels.put(model);
    }
  }

  /// Restore debt payments
  Future<void> _restoreDebtPayments(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = DebtPaymentModel()
        ..id = item['id'] as int
        ..debtId = item['debtId'] as int
        ..amount = (item['amount'] as num).toDouble()
        ..paymentDate = DateTime.parse(item['paymentDate'] as String)
        ..note = item['note'] as String?;
      await isar.debtPaymentModels.put(model);
    }
  }

  /// Restore recurring bills
  Future<void> _restoreRecurringBills(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = RecurringBillModel()
        ..id = item['id'] as int
        ..name = item['name'] as String
        ..amount = (item['amount'] as num).toDouble()
        ..currency = item['currency'] as String? ?? 'USD'
        ..categoryId = item['categoryId'] as int
        ..accountId = item['accountId'] as int
        ..frequency = item['frequency'] as String
        ..dayOfSchedule = item['dayOfSchedule'] as int? ?? 1
        ..nextDueDate = DateTime.parse(item['nextDueDate'] as String)
        ..reminderDaysBefore = item['reminderDaysBefore'] as int? ?? 3
        ..note = item['note'] as String?
        ..isActive = item['isActive'] as bool? ?? true
        ..createdAt = item['createdAt'] != null
            ? DateTime.parse(item['createdAt'] as String)
            : DateTime.now();
      await isar.recurringBillModels.put(model);
    }
  }

  /// Restore bill payments
  Future<void> _restoreBillPayments(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = BillPaymentModel()
        ..id = item['id'] as int
        ..billId = item['billId'] as int
        ..paidDate = DateTime.parse(item['paidDate'] as String)
        ..note = item['note'] as String?
        ..expenseId = item['expenseId'] as int?;
      await isar.billPaymentModels.put(model);
    }
  }

  /// Restore financial commitments
  Future<void> _restoreFinancialCommitments(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = FinancialCommitmentModel()
        ..id = item['id'] as int
        ..name = item['name'] as String
        ..description = item['description'] as String
        ..targetAmount = (item['targetAmount'] as num).toDouble()
        ..currentAmount = (item['currentAmount'] as num).toDouble()
        ..currency = item['currency'] as String
        ..deadline = DateTime.parse(item['deadline'] as String)
        ..accountId = item['accountId'] as int
        ..note = item['note'] as String?
        ..isCompleted = item['isCompleted'] as bool? ?? false
        ..createdAt = DateTime.parse(item['createdAt'] as String)
        ..updatedAt = DateTime.parse(item['updatedAt'] as String);
      await isar.financialCommitmentModels.put(model);
    }
  }

  /// Restore commitment contributions
  Future<void> _restoreCommitmentContributions(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = CommitmentContributionModel()
        ..id = item['id'] as int
        ..commitmentId = item['commitmentId'] as int
        ..amount = (item['amount'] as num).toDouble()
        ..date = DateTime.parse(item['date'] as String)
        ..note = item['note'] as String?;
      await isar.commitmentContributionModels.put(model);
    }
  }

  /// Restore notes
  Future<void> _restoreNotes(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = NoteModel()
        ..id = item['id'] as int
        ..title = item['title'] as String
        ..content = item['content'] as String?
        ..encryptedContent = item['encryptedContent'] as String?
        ..color = item['color'] as String
        ..attachmentPaths =
            List<String>.from(item['attachmentPaths'] as List<dynamic>? ?? [])
        ..voiceNotePath = item['voiceNotePath'] as String?
        ..checklistItems =
            (item['checklistItems'] as List<dynamic>? ?? []).map((ci) {
          return ChecklistItemModel()
            ..text = ci['text'] as String
            ..isChecked = ci['isChecked'] as bool? ?? false;
        }).toList()
        ..isLocked = item['isLocked'] as bool? ?? false
        ..createdAt = DateTime.parse(item['createdAt'] as String)
        ..updatedAt = DateTime.parse(item['updatedAt'] as String);
      await isar.noteModels.put(model);
    }
  }

  /// Restore reminders
  Future<void> _restoreReminders(
    Isar isar,
    List<dynamic>? data,
    String strategy,
  ) async {
    if (data == null) return;
    for (final item in data) {
      final model = ReminderModel()
        ..id = item['id'] as int
        ..title = item['title'] as String
        ..description = item['description'] as String?
        ..dateTime = DateTime.parse(item['dateTime'] as String)
        ..isCompleted = item['isCompleted'] as bool? ?? false
        ..priority = item['priority'] as String
        ..isRecurring = item['isRecurring'] as bool? ?? false
        ..recurringPattern = item['recurringPattern'] as String?
        ..recurringInterval = item['recurringInterval'] as int?
        ..recurringEndDate = item['recurringEndDate'] != null
            ? DateTime.parse(item['recurringEndDate'] as String)
            : null
        ..nextOccurrence = item['nextOccurrence'] != null
            ? DateTime.parse(item['nextOccurrence'] as String)
            : null
        ..linkedType = item['linkedType'] as String?
        ..linkedId = item['linkedId'] as int?
        ..createdAt = DateTime.parse(item['createdAt'] as String)
        ..updatedAt = DateTime.parse(item['updatedAt'] as String);
      await isar.reminderModels.put(model);
    }
  }
}
