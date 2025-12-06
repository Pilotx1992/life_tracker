import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class UpdateBill implements UseCase<bool, RecurringBill> {
  final BillRepository repository;

  UpdateBill(this.repository);

  @override
  Future<Either<Failure, bool>> call(RecurringBill params) async {
    return await repository.updateBill(params);
  }
}
