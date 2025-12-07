import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/financial_commitment_model.dart';
import 'package:life_tracker/features/finance/data/models/commitment_contribution_model.dart';

abstract class CommitmentLocalDataSource {
  Future<List<FinancialCommitmentModel>> getAllCommitments();
  Future<List<FinancialCommitmentModel>> getActiveCommitments();
  Future<List<FinancialCommitmentModel>> getCompletedCommitments();
  Future<FinancialCommitmentModel?> getCommitmentById(Id id);
  Future<Id> addCommitment(FinancialCommitmentModel commitment);
  Future<bool> updateCommitment(FinancialCommitmentModel commitment);
  Future<bool> deleteCommitment(Id id);

  // Contribution methods
  Future<List<CommitmentContributionModel>> getContributionsByCommitment(
    Id commitmentId,
  );
  Future<Id> addContribution(CommitmentContributionModel contribution);
  Future<bool> updateContribution(CommitmentContributionModel contribution);
  Future<bool> deleteContribution(Id id);

  // Helper method to recalculate commitment currentAmount
  Future<void> recalculateCommitmentAmount(Id commitmentId);
}

class CommitmentLocalDataSourceImpl implements CommitmentLocalDataSource {
  final DatabaseService _databaseService;

  CommitmentLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<FinancialCommitmentModel>> getAllCommitments() async {
    try {
      final isar = await _databaseService.database;
      final commitments =
          await isar.financialCommitmentModels.where().findAll();
      commitments.sort((a, b) => a.deadline.compareTo(b.deadline));
      return commitments;
    } catch (e) {
      throw CacheException('Failed to get commitments: $e');
    }
  }

  @override
  Future<List<FinancialCommitmentModel>> getActiveCommitments() async {
    try {
      final isar = await _databaseService.database;
      final commitments = await isar.financialCommitmentModels
          .filter()
          .isCompletedEqualTo(false)
          .findAll();
      commitments.sort((a, b) => a.deadline.compareTo(b.deadline));
      return commitments;
    } catch (e) {
      throw CacheException('Failed to get active commitments: $e');
    }
  }

  @override
  Future<List<FinancialCommitmentModel>> getCompletedCommitments() async {
    try {
      final isar = await _databaseService.database;
      final commitments = await isar.financialCommitmentModels
          .filter()
          .isCompletedEqualTo(true)
          .findAll();
      commitments.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      ); // Most recent first
      return commitments;
    } catch (e) {
      throw CacheException('Failed to get completed commitments: $e');
    }
  }

  @override
  Future<FinancialCommitmentModel?> getCommitmentById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.financialCommitmentModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get commitment: $e');
    }
  }

  @override
  Future<Id> addCommitment(FinancialCommitmentModel commitment) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.financialCommitmentModels.put(commitment);
      });
      return commitment.id;
    } catch (e) {
      throw CacheException('Failed to add commitment: $e');
    }
  }

  @override
  Future<bool> updateCommitment(FinancialCommitmentModel commitment) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        commitment.updatedAt = DateTime.now();
        // Recalculate isCompleted based on current vs target amount
        // This allows a completed commitment to become active again if target is increased
        commitment.isCompleted =
            commitment.currentAmount >= commitment.targetAmount;
        await isar.financialCommitmentModels.put(commitment);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update commitment: $e');
    }
  }

  @override
  Future<bool> deleteCommitment(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        // Delete associated contributions first
        final contributions = await isar.commitmentContributionModels
            .filter()
            .commitmentIdEqualTo(id)
            .findAll();
        await isar.commitmentContributionModels
            .deleteAll(contributions.map((c) => c.id).toList());

        // Delete the commitment
        await isar.financialCommitmentModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete commitment: $e');
    }
  }

  @override
  Future<List<CommitmentContributionModel>> getContributionsByCommitment(
    Id commitmentId,
  ) async {
    try {
      final isar = await _databaseService.database;
      final contributions = await isar.commitmentContributionModels
          .filter()
          .commitmentIdEqualTo(commitmentId)
          .findAll();
      contributions
          .sort((a, b) => b.date.compareTo(a.date)); // Most recent first
      return contributions;
    } catch (e) {
      throw CacheException('Failed to get contributions by commitment: $e');
    }
  }

  @override
  Future<Id> addContribution(CommitmentContributionModel contribution) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.commitmentContributionModels.put(contribution);
        // Recalculate commitment amount (within same transaction)
        await _recalculateCommitmentAmountInternal(
            isar, contribution.commitmentId,);
      });
      return contribution.id;
    } catch (e) {
      throw CacheException('Failed to add contribution: $e');
    }
  }

  @override
  Future<bool> updateContribution(
    CommitmentContributionModel contribution,
  ) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.commitmentContributionModels.put(contribution);
        // Recalculate commitment amount (within same transaction)
        await _recalculateCommitmentAmountInternal(
            isar, contribution.commitmentId,);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update contribution: $e');
    }
  }

  @override
  Future<bool> deleteContribution(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        final contribution = await isar.commitmentContributionModels.get(id);
        if (contribution != null) {
          final commitmentId = contribution.commitmentId;
          await isar.commitmentContributionModels.delete(id);
          // Recalculate commitment amount (within same transaction)
          await _recalculateCommitmentAmountInternal(isar, commitmentId);
        }
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete contribution: $e');
    }
  }

  @override
  Future<void> recalculateCommitmentAmount(Id commitmentId) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await _recalculateCommitmentAmountInternal(isar, commitmentId);
      });
    } catch (e) {
      throw CacheException('Failed to recalculate commitment amount: $e');
    }
  }

  /// Internal method to recalculate commitment amount without starting a new transaction.
  /// This should be called from within an existing writeTxn.
  Future<void> _recalculateCommitmentAmountInternal(
      Isar isar, Id commitmentId,) async {
    final commitment = await isar.financialCommitmentModels.get(commitmentId);
    if (commitment != null) {
      // Sum all contributions
      final contributions = await isar.commitmentContributionModels
          .filter()
          .commitmentIdEqualTo(commitmentId)
          .findAll();
      final total = contributions.fold<double>(0.0, (sum, c) => sum + c.amount);

      commitment.currentAmount = total;
      commitment.isCompleted =
          commitment.currentAmount >= commitment.targetAmount;
      commitment.updatedAt = DateTime.now();

      await isar.financialCommitmentModels.put(commitment);
    }
  }
}
