import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:life_tracker/core/database/database_service.dart';

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
import 'package:life_tracker/features/reminders/data/models/reminder_model.dart';
import 'package:life_tracker/core/services/backup_serializer.dart';

/// Service for creating and managing backups
class BackupService {
  BackupService._(); // Private constructor for singleton

  static final BackupService instance = BackupService._();

  static const String _backupDirName = 'backups';
  static const String _backupFileExtension = '.lifetracker';

  /// Get the backup directory
  Future<Directory> _getBackupDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDocDir.path, _backupDirName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Generate backup filename with timestamp
  String _generateBackupFileName() {
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    return 'backup_$timestamp$_backupFileExtension';
  }

  /// Encrypt data with password using AES (simplified - using SHA-256 for key derivation)
  /// Note: For production, consider using a proper AES encryption library
  String _encryptData(String data, String password) {
    // Derive key from password
    final keyBytes = utf8.encode(password);
    final hash = sha256.convert(keyBytes);

    // Simple XOR encryption (for production, use proper AES)
    final dataBytes = utf8.encode(data);
    final key = hash.bytes;
    final encrypted = List<int>.generate(
      dataBytes.length,
      (i) => dataBytes[i] ^ key[i % key.length],
    );

    return base64Encode(encrypted);
  }

  /// Decrypt data with password
  String _decryptData(String encryptedData, String password) {
    try {
      // Derive key from password
      final keyBytes = utf8.encode(password);
      final hash = sha256.convert(keyBytes);

      // Decrypt
      final encrypted = base64Decode(encryptedData);
      final key = hash.bytes;
      final decrypted = List<int>.generate(
        encrypted.length,
        (i) => encrypted[i] ^ key[i % key.length],
      );

      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Failed to decrypt backup: $e');
    }
  }

  /// Export all data from database to JSON
  Future<Map<String, dynamic>> _exportAllData() async {
    final isar = await DatabaseService.instance.database;

    final backupData = <String, dynamic>{
      'version': '1.0',
      'createdAt': DateTime.now().toIso8601String(),
      'data': <String, dynamic>{},
    };

    // Export all collections
    try {
      // Health data
      backupData['data']!['userProfiles'] =
          (await isar.userProfileModels.where().findAll())
              .map((e) => BackupSerializer.userProfileToJson(e))
              .toList();
      backupData['data']!['weights'] =
          (await isar.weightModels.where().findAll())
              .map((e) => BackupSerializer.weightToJson(e))
              .toList();
      backupData['data']!['medications'] =
          (await isar.medicationModels.where().findAll())
              .map((e) => BackupSerializer.medicationToJson(e))
              .toList();
      backupData['data']!['medicationIntakes'] =
          (await isar.medicationIntakeModels.where().findAll())
              .map((e) => BackupSerializer.medicationIntakeToJson(e))
              .toList();

      // Finance data
      backupData['data']!['accounts'] =
          (await isar.accountModels.where().findAll())
              .map((e) => BackupSerializer.accountToJson(e))
              .toList();
      backupData['data']!['categories'] =
          (await isar.categoryModels.where().findAll())
              .map((e) => BackupSerializer.categoryToJson(e))
              .toList();
      backupData['data']!['expenses'] =
          (await isar.expenseModels.where().findAll())
              .map((e) => BackupSerializer.expenseToJson(e))
              .toList();
      backupData['data']!['incomes'] =
          (await isar.incomeModels.where().findAll())
              .map((e) => BackupSerializer.incomeToJson(e))
              .toList();
      backupData['data']!['debts'] = (await isar.debtModels.where().findAll())
          .map((e) => BackupSerializer.debtToJson(e))
          .toList();
      backupData['data']!['debtPayments'] =
          (await isar.debtPaymentModels.where().findAll())
              .map((e) => BackupSerializer.debtPaymentToJson(e))
              .toList();
      backupData['data']!['recurringBills'] =
          (await isar.recurringBillModels.where().findAll())
              .map((e) => BackupSerializer.recurringBillToJson(e))
              .toList();
      backupData['data']!['billPayments'] =
          (await isar.billPaymentModels.where().findAll())
              .map((e) => BackupSerializer.billPaymentToJson(e))
              .toList();
      backupData['data']!['financialCommitments'] =
          (await isar.financialCommitmentModels.where().findAll())
              .map((e) => BackupSerializer.financialCommitmentToJson(e))
              .toList();
      backupData['data']!['commitmentContributions'] =
          (await isar.commitmentContributionModels.where().findAll())
              .map((e) => BackupSerializer.commitmentContributionToJson(e))
              .toList();

      // Notes data
      backupData['data']!['notes'] = (await isar.noteModels.where().findAll())
          .map((e) => BackupSerializer.noteToJson(e))
          .toList();

      // Reminders data
      backupData['data']!['reminders'] =
          (await isar.reminderModels.where().findAll())
              .map((e) => BackupSerializer.reminderToJson(e))
              .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error exporting data: $e');
      }
      rethrow;
    }

    return backupData;
  }

  /// Create a backup file
  Future<String> createBackup({String? password}) async {
    try {
      // Export all data
      final backupData = await _exportAllData();
      final jsonString = jsonEncode(backupData);

      // Encrypt if password provided
      final dataToWrite = password != null && password.isNotEmpty
          ? _encryptData(jsonString, password)
          : jsonString;

      // Save to file
      final backupDir = await _getBackupDirectory();
      final fileName = _generateBackupFileName();
      final file = File(p.join(backupDir.path, fileName));
      await file.writeAsString(dataToWrite);

      if (kDebugMode) {
        debugPrint('Backup created: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating backup: $e');
      }
      rethrow;
    }
  }

  /// List all backup files
  Future<List<BackupFileInfo>> listBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(_backupFileExtension))
          .toList();

      final backups = <BackupFileInfo>[];
      for (final file in files) {
        final stat = await file.stat();
        backups.add(
          BackupFileInfo(
            path: file.path,
            fileName: p.basename(file.path),
            size: stat.size,
            modified: stat.modified,
          ),
        );
      }

      // Sort by modified date (newest first)
      backups.sort((a, b) => b.modified.compareTo(a.modified));

      return backups;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing backups: $e');
      }
      return [];
    }
  }

  /// Delete a backup file
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting backup: $e');
      }
      return false;
    }
  }

  /// Read and decrypt backup file
  Future<Map<String, dynamic>> readBackup(
    String filePath, {
    String? password,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final encryptedData = await file.readAsString();

      // Try to decrypt if password provided, otherwise assume plain JSON
      String jsonString;
      if (password != null && password.isNotEmpty) {
        jsonString = _decryptData(encryptedData, password);
      } else {
        // Try to parse as JSON first (might be unencrypted)
        try {
          jsonDecode(encryptedData);
          jsonString = encryptedData;
        } catch (_) {
          throw Exception(
            'Backup appears to be encrypted but no password provided',
          );
        }
      }

      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      return backupData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error reading backup: $e');
      }
      rethrow;
    }
  }

  /// Get backup file size in human-readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Information about a backup file
class BackupFileInfo {
  final String path;
  final String fileName;
  final int size;
  final DateTime modified;

  BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.size,
    required this.modified,
  });

  String get formattedSize => BackupService.instance.formatFileSize(size);
}
