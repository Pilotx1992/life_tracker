import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class GetOverdueBills implements UseCase<List<RecurringBill>, NoParams> {
  final BillRepository repository;

  GetOverdueBills(this.repository);

  @override
  Future<Either<Failure, List<RecurringBill>>> call(NoParams params) async {
    return await repository.getOverdueBills();
  }
}
