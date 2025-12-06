import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class AddBill implements UseCase<Id, RecurringBill> {
  final BillRepository repository;

  AddBill(this.repository);

  @override
  Future<Either<Failure, Id>> call(RecurringBill params) async {
    return await repository.addBill(params);
  }
}
