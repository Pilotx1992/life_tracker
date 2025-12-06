import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/features/finance/domain/usecases/add_transfer.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_transfers.dart';
import 'package:life_tracker/features/finance/domain/usecases/get_transfers_by_account.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';

// Providers for use cases
final addTransferUseCaseProvider =
    Provider((ref) => AddTransfer(ref.read(transferRepositoryProvider)));
final getTransfersUseCaseProvider =
    Provider((ref) => GetTransfers(ref.read(transferRepositoryProvider)));
final getTransfersByAccountUseCaseProvider = Provider(
  (ref) => GetTransfersByAccount(ref.read(transferRepositoryProvider)),
);

// StateNotifier for managing transfer-related state
class TransferNotifier extends StateNotifier<AsyncValue<List<Transfer>>> {
  final AddTransfer _addTransfer;
  final GetTransfers _getTransfers;
  final GetTransfersByAccount _getTransfersByAccount;

  TransferNotifier({
    required AddTransfer addTransfer,
    required GetTransfers getTransfers,
    required GetTransfersByAccount getTransfersByAccount,
  })  : _addTransfer = addTransfer,
        _getTransfers = getTransfers,
        _getTransfersByAccount = getTransfersByAccount,
        super(const AsyncValue.loading()) {
    loadTransfers();
  }

  Future<void> loadTransfers() async {
    state = const AsyncValue.loading();
    final result = await _getTransfers(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (transfers) => AsyncValue.data(transfers),
    );
  }

  Future<void> loadTransfersByAccount(Id accountId) async {
    state = const AsyncValue.loading();
    final result = await _getTransfersByAccount(
      GetTransfersByAccountParams(accountId: accountId),
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (transfers) => AsyncValue.data(transfers),
    );
  }

  Future<void> addTransferEntry(Transfer transfer) async {
    final result = await _addTransfer(transfer);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (id) {
        // Reload transfers after adding
        loadTransfers();
      },
    );
  }
}

// Provider for TransferNotifier
final transferNotifierProvider =
    StateNotifierProvider<TransferNotifier, AsyncValue<List<Transfer>>>((ref) {
  return TransferNotifier(
    addTransfer: ref.read(addTransferUseCaseProvider),
    getTransfers: ref.read(getTransfersUseCaseProvider),
    getTransfersByAccount: ref.read(getTransfersByAccountUseCaseProvider),
  );
});

// Provider for transfer list
final transferListProvider = Provider<AsyncValue<List<Transfer>>>((ref) {
  return ref.watch(transferNotifierProvider);
});

// Provider for transfers by account
final transferListByAccountProvider =
    Provider.family<AsyncValue<List<Transfer>>, Id>((ref, accountId) {
  final notifier = ref.read(transferNotifierProvider.notifier);
  notifier.loadTransfersByAccount(accountId);
  return ref.watch(transferNotifierProvider);
});
