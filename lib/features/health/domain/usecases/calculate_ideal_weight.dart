import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';

class CalculateIdealWeight
    implements UseCase<Map<String, double>, IdealWeightParams> {
  @override
  Future<Either<Failure, Map<String, double>>> call(
    IdealWeightParams params,
  ) async {
    if (params.height <= 0) {
      return const Left(CalculationFailure('Height must be a positive value'));
    }

    // Using Devine formula for ideal weight (in kg)
    // For men: 50 kg + 2.3 kg for each inch over 5 feet
    // For women: 45.5 kg + 2.3 kg for each inch over 5 feet

    // Convert height from cm to inches
    final double heightInInches = params.height / 2.54;

    // Convert 5 feet to inches
    const double fiveFeetInInches = 60.0;

    if (heightInInches <= fiveFeetInInches) {
      // For heights 5 feet or less, a simpler approach or a different formula might be needed.
      // For now, we'll return a basic range.
      return const Right({
        'min': 45.0,
        'max': 60.0,
      });
    }

    double idealWeightBase;
    if (params.isMale) {
      idealWeightBase = 50.0;
    } else {
      idealWeightBase = 45.5;
    }

    final double inchesOverFiveFeet = heightInInches - fiveFeetInInches;
    final double idealWeight = idealWeightBase + (2.3 * inchesOverFiveFeet);

    // Provide a range (e.g., +/- 10%)
    final double minIdealWeight = idealWeight * 0.9;
    final double maxIdealWeight = idealWeight * 1.1;

    return Right({
      'min': minIdealWeight,
      'max': maxIdealWeight,
    });
  }
}

class IdealWeightParams extends Equatable {
  final double height; // in cm
  final bool isMale;

  const IdealWeightParams({required this.height, required this.isMale});

  @override
  List<Object?> get props => [height, isMale];
}
