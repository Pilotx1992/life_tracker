import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/transfer_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/transfer_model.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/features/finance/domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferLocalDataSource localDataSource;

  TransferRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Transfer>>> getAllTransfers() async {
    try {
      final transferModels = await localDataSource.getAllTransfers();
      final transfers =
          transferModels.map((model) => model.toEntity()).toList();
      return Right(transfers);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transfer>>> getTransfersByAccount(
    Id accountId,
  ) async {
    try {
      final transferModels =
          await localDataSource.getTransfersByAccount(accountId);
      final transfers =
          transferModels.map((model) => model.toEntity()).toList();
      return Right(transfers);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addTransfer(Transfer transfer) async {
    try {
      final transferModel = TransferModel.fromEntity(transfer);
      final id = await localDataSource.addTransfer(transferModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTransfer(Id id) async {
    try {
      final result = await localDataSource.deleteTransfer(id);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
