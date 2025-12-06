import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';

class CalculateNetPosition implements UseCase<double, NoParams> {
  final DebtRepository repository;

  CalculateNetPosition(this.repository);

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return await repository.calculateNetPosition();
  }
}
