import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';

class DeleteAccountParams {
  final Id id;

  DeleteAccountParams({required this.id});
}

class DeleteAccount implements UseCase<bool, DeleteAccountParams> {
  final AccountRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteAccountParams params) async {
    return await repository.deleteAccount(params.id);
  }
}
