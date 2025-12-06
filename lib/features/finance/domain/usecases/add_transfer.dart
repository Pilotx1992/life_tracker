import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/features/finance/domain/repositories/transfer_repository.dart';

class AddTransfer implements UseCase<Id, Transfer> {
  final TransferRepository repository;

  AddTransfer(this.repository);

  @override
  Future<Either<Failure, Id>> call(Transfer params) async {
    return await repository.addTransfer(params);
  }
}
