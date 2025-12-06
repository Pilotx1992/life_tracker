import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';

abstract class TransferRepository {
  Future<Either<Failure, List<Transfer>>> getAllTransfers();
  Future<Either<Failure, List<Transfer>>> getTransfersByAccount(Id accountId);
  Future<Either<Failure, Id>> addTransfer(Transfer transfer);
  Future<Either<Failure, bool>> deleteTransfer(Id id);
}
