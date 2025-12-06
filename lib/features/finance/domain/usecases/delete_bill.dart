import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class DeleteBill implements UseCase<bool, Id> {
  final BillRepository repository;

  DeleteBill(this.repository);

  @override
  Future<Either<Failure, bool>> call(Id params) async {
    return await repository.deleteBill(params);
  }
}
