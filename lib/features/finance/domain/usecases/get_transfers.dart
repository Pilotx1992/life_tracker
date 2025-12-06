import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/features/finance/domain/repositories/transfer_repository.dart';

class GetTransfers implements UseCase<List<Transfer>, NoParams> {
  final TransferRepository repository;

  GetTransfers(this.repository);

  @override
  Future<Either<Failure, List<Transfer>>> call(NoParams params) async {
    return await repository.getAllTransfers();
  }
}
