import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class DeleteBillPayment implements UseCase<bool, Id> {
  final BillRepository repository;

  DeleteBillPayment(this.repository);

  @override
  Future<Either<Failure, bool>> call(Id params) async {
    return await repository.deletePayment(params);
  }
}
