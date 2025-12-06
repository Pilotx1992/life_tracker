import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/transfer_model.dart';

abstract class TransferLocalDataSource {
  Future<List<TransferModel>> getAllTransfers();
  Future<List<TransferModel>> getTransfersByAccount(Id accountId);
  Future<Id> addTransfer(TransferModel transfer);
  Future<bool> deleteTransfer(Id id);
}

class TransferLocalDataSourceImpl implements TransferLocalDataSource {
  final DatabaseService _databaseService;

  TransferLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<TransferModel>> getAllTransfers() async {
    try {
      final isar = await _databaseService.database;
      final transfers = await isar.transferModels.where().findAll();
      transfers
          .sort((a, b) => b.date.compareTo(a.date)); // Sort descending by date
      return transfers;
    } catch (e) {
      throw CacheException('Failed to get transfers: $e');
    }
  }

  @override
  Future<List<TransferModel>> getTransfersByAccount(Id accountId) async {
    try {
      final isar = await _databaseService.database;
      // Get transfers where account is the source
      final fromTransfers = await isar.transferModels
          .filter()
          .fromAccountIdEqualTo(accountId)
          .findAll();
      // Get transfers where account is the destination
      final toTransfers = await isar.transferModels
          .filter()
          .toAccountIdEqualTo(accountId)
          .findAll();
      // Combine and remove duplicates
      final allTransfers = <TransferModel>[];
      final seenIds = <Id>{};
      for (final transfer in fromTransfers) {
        if (!seenIds.contains(transfer.id)) {
          allTransfers.add(transfer);
          seenIds.add(transfer.id);
        }
      }
      for (final transfer in toTransfers) {
        if (!seenIds.contains(transfer.id)) {
          allTransfers.add(transfer);
          seenIds.add(transfer.id);
        }
      }
      allTransfers.sort((a, b) => b.date.compareTo(a.date));
      return allTransfers;
    } catch (e) {
      throw CacheException('Failed to get transfers by account: $e');
    }
  }

  @override
  Future<Id> addTransfer(TransferModel transfer) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.transferModels.put(transfer);
      });
      return transfer.id;
    } catch (e) {
      throw CacheException('Failed to add transfer: $e');
    }
  }

  @override
  Future<bool> deleteTransfer(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.transferModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete transfer: $e');
    }
  }
}
