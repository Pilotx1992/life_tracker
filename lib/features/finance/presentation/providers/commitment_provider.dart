import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_commitment.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_commitment.dart';
import 'package:life_tracker/features/finance/domain/usecases/delete_commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_active_commitments.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_commitment_by_id.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_commitment_contributions.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_commitments.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_completed_commitments.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_commitment.dart';
import 'package:life_tracker/features/finance/domain/usecases/update_commitment_contribution.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';

// Providers for use cases (dependency injection)
final addCommitmentUseCaseProvider =
    Provider((ref) => AddCommitment(ref.read(commitmentRepositoryProvider)));
final getCommitmentsUseCaseProvider =
    Provider((ref) => GetCommitments(ref.read(commitmentRepositoryProvider)));
final getActiveCommitmentsUseCaseProvider = Provider(
  (ref) => GetActiveCommitments(ref.read(commitmentRepositoryProvider)),
);
final getCompletedCommitmentsUseCaseProvider = Provider(
  (ref) => GetCompletedCommitments(ref.read(commitmentRepositoryProvider)),
);
final getCommitmentByIdUseCaseProvider = Provider(
  (ref) => GetCommitmentById(ref.read(commitmentRepositoryProvider)),
);
final updateCommitmentUseCaseProvider =
    Provider((ref) => UpdateCommitment(ref.read(commitmentRepositoryProvider)));
final deleteCommitmentUseCaseProvider =
    Provider((ref) => DeleteCommitment(ref.read(commitmentRepositoryProvider)));
final addCommitmentContributionUseCaseProvider = Provider(
  (ref) => AddCommitmentContribution(ref.read(commitmentRepositoryProvider)),
);
final getCommitmentContributionsUseCaseProvider = Provider(
  (ref) => GetCommitmentContributions(ref.read(commitmentRepositoryProvider)),
);
final updateCommitmentContributionUseCaseProvider = Provider(
  (ref) => UpdateCommitmentContribution(ref.read(commitmentRepositoryProvider)),
);
final deleteCommitmentContributionUseCaseProvider = Provider(
  (ref) => DeleteCommitmentContribution(ref.read(commitmentRepositoryProvider)),
);

// StateNotifier for managing commitment-related state
class CommitmentNotifier
    extends StateNotifier<AsyncValue<List<FinancialCommitment>>> {
  final AddCommitment _addCommitment;
  final GetCommitments _getCommitments;
  final GetActiveCommitments _getActiveCommitments;
  final GetCompletedCommitments _getCompletedCommitments;
  final GetCommitmentById _getCommitmentById;
  final UpdateCommitment _updateCommitment;
  final DeleteCommitment _deleteCommitment;
  final AddCommitmentContribution _addContribution;
  final GetCommitmentContributions _getContributions;
  final UpdateCommitmentContribution _updateContribution;
  final DeleteCommitmentContribution _deleteContribution;
  final AccountNotifier? _accountNotifier;

  CommitmentNotifier({
    required AddCommitment addCommitment,
    required GetCommitments getCommitments,
    required GetActiveCommitments getActiveCommitments,
    required GetCompletedCommitments getCompletedCommitments,
    required GetCommitmentById getCommitmentById,
    required UpdateCommitment updateCommitment,
    required DeleteCommitment deleteCommitment,
    required AddCommitmentContribution addContribution,
    required GetCommitmentContributions getContributions,
    required UpdateCommitmentContribution updateContribution,
    required DeleteCommitmentContribution deleteContribution,
    AccountNotifier? accountNotifier,
  })  : _addCommitment = addCommitment,
        _getCommitments = getCommitments,
        _getActiveCommitments = getActiveCommitments,
        _getCompletedCommitments = getCompletedCommitments,
        _getCommitmentById = getCommitmentById,
        _updateCommitment = updateCommitment,
        _deleteCommitment = deleteCommitment,
        _addContribution = addContribution,
        _getContributions = getContributions,
        _updateContribution = updateContribution,
        _deleteContribution = deleteContribution,
        _accountNotifier = accountNotifier,
        super(const AsyncValue.loading()) {
    loadCommitments();
  }

  Future<void> loadCommitments() async {
    state = const AsyncValue.loading();
    final result = await _getCommitments(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (commitments) => AsyncValue.data(commitments),
    );
  }

  Future<void> loadActiveCommitments() async {
    state = const AsyncValue.loading();
    final result = await _getActiveCommitments(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (commitments) => AsyncValue.data(commitments),
    );
  }

  Future<List<FinancialCommitment>> getCompletedCommitments() async {
    final result = await _getCompletedCommitments(NoParams());
    return result.fold(
      (failure) => <FinancialCommitment>[],
      (commitments) => commitments,
    );
  }

  Future<FinancialCommitment?> getCommitmentById(Id id) async {
    final result = await _getCommitmentById(id);
    return result.fold(
      (failure) => null,
      (commitment) => commitment,
    );
  }

  Future<void> addCommitmentEntry(FinancialCommitment commitment) async {
    final result = await _addCommitment(commitment);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) => loadCommitments(), // Reload commitments after adding
    );
  }

  Future<void> updateCommitmentEntry(FinancialCommitment commitment) async {
    final result = await _updateCommitment(commitment);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadCommitments(), // Reload commitments after updating
    );
  }

  Future<void> deleteCommitmentEntry(Id id) async {
    final result = await _deleteCommitment(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadCommitments(), // Reload commitments after deleting
    );
  }

  Future<void> addContribution(CommitmentContribution contribution) async {
    final result = await _addContribution(contribution);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) async {
        // Update account balance (deduct from account)
        if (_accountNotifier != null) {
          final commitment = await getCommitmentById(contribution.commitmentId);
          if (commitment != null) {
            // Get account from state
            final accountsState = _accountNotifier.state;
            accountsState.whenData((accounts) {
              if (accounts.isNotEmpty) {
                final account = accounts.firstWhere(
                  (a) => a.id == commitment.accountId,
                  orElse: () => accounts.first,
                );
                if (account.id != null) {
                  final updatedAccount = account.copyWith(
                    balance: account.balance - contribution.amount,
                  );
                  _accountNotifier.updateAccountEntry(updatedAccount);
                }
              }
            });
          }
        }
        loadCommitments(); // Reload to update currentAmount
      },
    );
  }

  Future<List<CommitmentContribution>> getContributionsByCommitment(
    Id commitmentId,
  ) async {
    final result = await _getContributions(commitmentId);
    return result.fold(
      (failure) => <CommitmentContribution>[],
      (contributions) => contributions,
    );
  }

  Future<void> updateContribution(CommitmentContribution contribution) async {
    final result = await _updateContribution(contribution);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadCommitments(), // Reload to update currentAmount
    );
  }

  Future<void> deleteContribution(Id id, Id commitmentId) async {
    final result = await _deleteContribution(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadCommitments(), // Reload to update currentAmount
    );
  }
}

final commitmentNotifierProvider = StateNotifierProvider<CommitmentNotifier,
    AsyncValue<List<FinancialCommitment>>>((ref) {
  return CommitmentNotifier(
    addCommitment: ref.read(addCommitmentUseCaseProvider),
    getCommitments: ref.read(getCommitmentsUseCaseProvider),
    getActiveCommitments: ref.read(getActiveCommitmentsUseCaseProvider),
    getCompletedCommitments: ref.read(getCompletedCommitmentsUseCaseProvider),
    getCommitmentById: ref.read(getCommitmentByIdUseCaseProvider),
    updateCommitment: ref.read(updateCommitmentUseCaseProvider),
    deleteCommitment: ref.read(deleteCommitmentUseCaseProvider),
    addContribution: ref.read(addCommitmentContributionUseCaseProvider),
    getContributions: ref.read(getCommitmentContributionsUseCaseProvider),
    updateContribution: ref.read(updateCommitmentContributionUseCaseProvider),
    deleteContribution: ref.read(deleteCommitmentContributionUseCaseProvider),
    accountNotifier: ref.read(accountNotifierProvider.notifier),
  );
});
