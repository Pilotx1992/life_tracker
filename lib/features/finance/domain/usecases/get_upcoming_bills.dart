import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class GetUpcomingBills implements UseCase<List<RecurringBill>, DateTime> {
  final BillRepository repository;

  GetUpcomingBills(this.repository);

  @override
  Future<Either<Failure, List<RecurringBill>>> call(DateTime endDate) async {
    return await repository.getUpcomingBills(endDate);
  }
}
