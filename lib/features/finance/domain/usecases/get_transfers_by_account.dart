import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/features/finance/domain/repositories/transfer_repository.dart';

class GetTransfersByAccountParams {
  final Id accountId;

  GetTransfersByAccountParams({required this.accountId});
}

class GetTransfersByAccount
    implements UseCase<List<Transfer>, GetTransfersByAccountParams> {
  final TransferRepository repository;

  GetTransfersByAccount(this.repository);

  @override
  Future<Either<Failure, List<Transfer>>> call(
    GetTransfersByAccountParams params,
  ) async {
    return await repository.getTransfersByAccount(params.accountId);
  }
}
