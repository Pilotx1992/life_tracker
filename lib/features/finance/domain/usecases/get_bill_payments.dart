import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/entities/bill_payment.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';

class GetBillPayments implements UseCase<List<BillPayment>, Id> {
  final BillRepository repository;

  GetBillPayments(this.repository);

  @override
  Future<Either<Failure, List<BillPayment>>> call(Id params) async {
    return await repository.getPaymentsByBill(params);
  }
}
