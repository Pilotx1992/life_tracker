import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class GetBillById implements UseCase<RecurringBill?, Id> {
  final BillRepository repository;

  GetBillById(this.repository);

  @override
  Future<Either<Failure, RecurringBill?>> call(Id params) async {
    return await repository.getBillById(params);
  }
}
