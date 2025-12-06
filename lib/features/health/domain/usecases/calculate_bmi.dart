import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';

class CalculateBmi implements UseCase<double, BmiParams> {
  @override
  Future<Either<Failure, double>> call(BmiParams params) async {
    if (params.weight <= 0 || params.height <= 0) {
      return const Left(
        CalculationFailure('Weight and height must be positive values'),
      );
    }
    // BMI formula: weight (kg) / (height (m))^2
    final double heightInMeters =
        params.height / 100; // Assuming height is in cm
    final double bmi = params.weight / (heightInMeters * heightInMeters);
    return Right(bmi);
  }
}

class BmiParams extends Equatable {
  final double weight;
  final double height;

  const BmiParams({required this.weight, required this.height});

  @override
  List<Object?> get props => [weight, height];
}
