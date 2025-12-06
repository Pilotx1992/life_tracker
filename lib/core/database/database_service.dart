import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import your Isar collection schemas here as you create them.
// For example:
// import 'package:life_tracker/features/health/data/models/weight_entry.dart';
// import 'package:life_tracker/features/finance/data/models/transaction.dart';

import 'package:life_tracker/features/finance/data/models/account_model.dart';
import 'package:life_tracker/features/health/data/models/user_profile_model.dart';

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
    // Note: encryption configuration can be added here when Isar API allows it.
    // Open the Isar instance with all your collection schemas.
    // As you create feature models (e.g., WeightEntry), add their schemas here.
    return Isar.open(
      [UserProfileModelSchema, AccountModelSchema], // e.g., [WeightEntrySchema, TransactionSchema],
      directory: dir.path,
      inspector: true, // Useful for debugging
    );
  }
}