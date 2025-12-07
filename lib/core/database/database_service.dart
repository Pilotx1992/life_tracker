import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import your Isar collection schemas here as you create them.
// For example:
// import 'package:life_tracker/features/health/data/models/weight_entry.dart';
// import 'package:life_tracker/features/finance/data/models/transaction.dart';

// Health models
import 'package:life_tracker/features/health/data/models/user_profile_model.dart';
import 'package:life_tracker/features/health/data/models/weight_model.dart';
import 'package:life_tracker/features/health/data/models/medication_model.dart';
import 'package:life_tracker/features/health/data/models/medication_intake_model.dart';

// Finance models
import 'package:life_tracker/features/finance/data/models/account_model.dart';
import 'package:life_tracker/features/finance/data/models/category_model.dart';
import 'package:life_tracker/features/finance/data/models/expense_model.dart';
import 'package:life_tracker/features/finance/data/models/income_model.dart';
import 'package:life_tracker/features/finance/data/models/debt_model.dart';
import 'package:life_tracker/features/finance/data/models/debt_payment_model.dart';
import 'package:life_tracker/features/finance/data/models/bill_payment_model.dart';
import 'package:life_tracker/features/finance/data/models/recurring_bill_model.dart';
import 'package:life_tracker/features/finance/data/models/financial_commitment_model.dart';
import 'package:life_tracker/features/finance/data/models/commitment_contribution_model.dart';
import 'package:life_tracker/features/finance/data/models/transfer_model.dart';

// Notes models
import 'package:life_tracker/features/notes/data/models/note_model.dart';
// Note: ChecklistItemModel is embedded, not a separate collection

// Reminders models
import 'package:life_tracker/features/reminders/data/models/reminder_model.dart';

// A singleton service to manage the Isar database instance.
class DatabaseService {
  // Private constructor
  DatabaseService._() {
    // Initialize DB future immediately so callers can await `database`.
    _db = _openDB();
  }

  // Singleton instance
  static final DatabaseService instance = DatabaseService._();

  late final Future<Isar> _db;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _encryptionKeyKey = 'isar_encryption_key';

  Future<Isar> get database => _db;


  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: _encryptionKeyKey);
    if (key == null) {
      // Generate a new key if one doesn't exist
      // In a real app, you'd use a more robust key generation method
      key = List<int>.generate(32, (i) => i).join(); // Placeholder key
      await _secureStorage.write(key: _encryptionKeyKey, value: key);
    }
    return key;
  }

  Future<Isar> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    // Ensure an encryption key exists (reserved for future use). Calling the
    // helper removes the unused-private warning and prepares the codepath
    // for adding Isar encryption when desired.
    try {
      await _getEncryptionKey();
    } catch (_) {
      // If secure storage is unavailable, ignore and continue opening DB.
    }
    
    final schemas = [
      // Health schemas
      UserProfileModelSchema,
      WeightModelSchema,
      MedicationModelSchema,
      MedicationIntakeModelSchema,
      // Finance schemas
      AccountModelSchema,
      CategoryModelSchema,
      ExpenseModelSchema,
      IncomeModelSchema,
      DebtModelSchema,
      DebtPaymentModelSchema,
      BillPaymentModelSchema,
      RecurringBillModelSchema,
      FinancialCommitmentModelSchema,
      CommitmentContributionModelSchema,
      TransferModelSchema,
      // Notes schemas
      NoteModelSchema,
      // Note: ChecklistItemModel is embedded, not a separate collection
      // Reminders schemas
      ReminderModelSchema,
    ];
    
    // Try to open the database
    try {
      return await Isar.open(
        schemas,
        directory: dir.path,
        inspector: true, // Useful for debugging
      );
    } catch (e) {
      // If opening fails (e.g., schema mismatch), delete old database and recreate
      // Try to delete database files manually
      final dbPath = '${dir.path}/default.isar';
      final lockPath = '${dir.path}/default.isar.lock';
      try {
        final dbFile = File(dbPath);
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        final lockFile = File(lockPath);
        if (await lockFile.exists()) {
          await lockFile.delete();
        }
      } catch (_) {
        // Ignore file deletion errors
      }
      
      // Now try to open again with a fresh database
      return await Isar.open(
        schemas,
        directory: dir.path,
        inspector: true,
      );
    }
  }
}